import SwiftUI
import UIKit

struct PageCurlView<Content: View>: UIViewControllerRepresentable {
    let pageCount: Int
    @Binding var currentPage: Int
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
        pageVC.view.backgroundColor = .clear

        let initialVC = context.coordinator.makeHostingController(for: currentPage)
        pageVC.setViewControllers([initialVC], direction: .forward, animated: false)
        return pageVC
    }

    func updateUIViewController(_ pageVC: UIPageViewController, context: Context) {
        context.coordinator.parent = self
        guard let current = pageVC.viewControllers?.first as? JournalPageHostingController,
              current.pageIndex != currentPage else { return }
        let direction: UIPageViewController.NavigationDirection = current.pageIndex < currentPage ? .forward : .reverse
        let newVC = context.coordinator.makeHostingController(for: currentPage)
        pageVC.setViewControllers([newVC], direction: direction, animated: true)
    }

    // MARK: - Coordinator

    class Coordinator: NSObject, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
        var parent: PageCurlView

        init(_ parent: PageCurlView) {
            self.parent = parent
        }

        func makeHostingController(for index: Int) -> JournalPageHostingController {
            let vc = JournalPageHostingController(rootView: parent.content(index))
            vc.pageIndex = index
            vc.view.backgroundColor = .clear
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
