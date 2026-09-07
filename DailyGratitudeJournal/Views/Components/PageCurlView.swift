import SwiftUI
import UIKit

/// The paper colour behind each page. `.pageCurl` renders the curl from the
/// page's own backing layer, so pages must be opaque — a transparent page
/// curls into a black or ghosted sheet instead of paper.
private let journalPaperColor = UIColor(red: 1.0, green: 0.973, blue: 0.906, alpha: 1.0)

struct PageCurlView<Content: View>: UIViewControllerRepresentable {
    let pageCount: Int
    @Binding var currentPage: Int
    /// Changes whenever the visible page's data changes, so the page can be
    /// rebuilt. Rebuilding is necessary because SwiftData loads asynchronously
    /// and a page is often constructed before its entries exist.
    let contentVersion: Int
    let content: (Int) -> Content

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIPageViewController {
        let pageVC = UIPageViewController(
            transitionStyle: .pageCurl,
            navigationOrientation: .horizontal,
            options: [.spineLocation: UIPageViewController.SpineLocation.min.rawValue]
        )
        pageVC.dataSource = context.coordinator
        pageVC.delegate = context.coordinator
        pageVC.view.backgroundColor = journalPaperColor
        // The back of a curling page is drawn by UIKit; without this it
        // mirrors the front and reads as a printing error.
        pageVC.isDoubleSided = false

        context.coordinator.lastRenderedVersion = contentVersion
        let initialVC = context.coordinator.makeHostingController(for: currentPage)
        pageVC.setViewControllers([initialVC], direction: .forward, animated: false)
        return pageVC
    }

    func updateUIViewController(_ pageVC: UIPageViewController, context: Context) {
        context.coordinator.parent = self

        guard pageCount > 0,
              currentPage >= 0, currentPage < pageCount,
              let current = pageVC.viewControllers?.first as? JournalPageHostingController else { return }

        // Same page, but its data may have changed. The page must be rebuilt
        // rather than have its rootView swapped in place: pageCurl renders
        // through a layer transform, and mutating a hosting controller's
        // rootView inside that transform lays the content out at the wrong
        // size, leaving it magnified and clipped.
        guard current.pageIndex != currentPage else {
            if context.coordinator.lastRenderedVersion != contentVersion {
                context.coordinator.lastRenderedVersion = contentVersion
                let coordinator = context.coordinator
                let page = currentPage
                // Deferred to the next runloop pass. Rebuilding mid-layout,
                // while the container still has provisional bounds, leaves the
                // new page sized to those bounds — it renders magnified and
                // clipped for the life of the page.
                DispatchQueue.main.async { [weak pageVC] in
                    guard let pageVC, pageVC.view.bounds.width > 0 else { return }
                    guard let showing = pageVC.viewControllers?.first as? JournalPageHostingController,
                          showing.pageIndex == page else { return }
                    let refreshed = coordinator.makeHostingController(for: page)
                    pageVC.setViewControllers([refreshed], direction: .forward, animated: false)
                }
            }
            return
        }

        context.coordinator.lastRenderedVersion = contentVersion

        let direction: UIPageViewController.NavigationDirection = current.pageIndex < currentPage ? .forward : .reverse
        let newVC = context.coordinator.makeHostingController(for: currentPage)
        pageVC.setViewControllers([newVC], direction: direction, animated: true)
    }

    // MARK: - Coordinator

    class Coordinator: NSObject, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
        var parent: PageCurlView
        var lastRenderedVersion: Int = 0

        init(_ parent: PageCurlView) {
            self.parent = parent
        }

        func makeHostingController(for index: Int) -> JournalPageHostingController {
            let vc = JournalPageHostingController(rootView: parent.content(index))
            vc.pageIndex = index
            vc.view.backgroundColor = journalPaperColor
            vc.view.isOpaque = true
            return vc
        }

        func pageViewController(_ pvc: UIPageViewController,
                                viewControllerBefore vc: UIViewController) -> UIViewController? {
            guard let hc = vc as? JournalPageHostingController, hc.pageIndex > 0 else { return nil }
            return makeHostingController(for: hc.pageIndex - 1)
        }

        func pageViewController(_ pvc: UIPageViewController,
                                viewControllerAfter vc: UIViewController) -> UIViewController? {
            guard let hc = vc as? JournalPageHostingController,
                  hc.pageIndex < parent.pageCount - 1 else { return nil }
            return makeHostingController(for: hc.pageIndex + 1)
        }

        func pageViewController(_ pvc: UIPageViewController,
                                didFinishAnimating finished: Bool,
                                previousViewControllers: [UIViewController],
                                transitionCompleted completed: Bool) {
            guard completed,
                  let hc = pvc.viewControllers?.first as? JournalPageHostingController else { return }
            parent.currentPage = hc.pageIndex
        }
    }
}

final class JournalPageHostingController: UIHostingController<AnyView> {
    var pageIndex: Int = 0

    init<V: View>(rootView: V) {
        super.init(rootView: AnyView(rootView))
    }

    @MainActor required dynamic init?(coder: NSCoder) {
        fatalError("init(coder:) not supported")
    }
}
