import Workflow
import WorkflowUI
import BackStackContainer
import ReactiveSwift
import Result


// MARK: Input and Output

struct TodoWorkflow: Workflow {
    var name: String

    enum Output {
        case back
    }
}


// MARK: State and Initialization

extension TodoWorkflow {

    struct State {
        var todos: [TodoModel]
        var step: Step
        enum Step {
            // Showing the list of todo items.
            case list
            // Editing a single item. The state holds the index so it can be updated when a save action is received.
            case edit(index: Int)
        }
    }

    func makeInitialState() -> TodoWorkflow.State {
        return State(
            todos: [TodoModel(
                title: "Take the cat for a walk",
                note: "Cats really need their outside sunshine time. Don't forget to walk Charlie. Hamilton is less excited about the prospect.")
            ],
            step: .list)
    }

    func workflowDidChange(from previousWorkflow: TodoWorkflow, state: inout State) {

    }
}


// MARK: Actions

extension TodoWorkflow {

    enum ListAction: WorkflowAction {

        typealias WorkflowType = TodoWorkflow

        case back
        case editTodo(index: Int)
        case newTodo

        func apply(toState state: inout TodoWorkflow.State) -> TodoWorkflow.Output? {

            switch self {
            case .back:
                return .back

            case .editTodo(index: let index):
                state.step = .edit(index: index)

            case .newTodo:
                // Append a new todo model to the end of the list.
                state.todos.append(TodoModel(
                    title: "New Todo",
                    note: ""))
            }

            return nil
        }
    }

    enum EditAction: WorkflowAction {

        typealias WorkflowType = TodoWorkflow

        case discardChanges
        case saveChanges(index: Int, todo: TodoModel)

        func apply(toState state: inout TodoWorkflow.State) -> TodoWorkflow.Output? {
            guard case .edit = state.step else {
                fatalError("Received edit action when state was not `.edit`.")
            }

            switch self {

            case .discardChanges:
                state.step = .list

            case .saveChanges(index: let index, todo: let updatedTodo):
                state.todos[index] = updatedTodo

            }
            // Return to the list view for either a discard or save action.
            state.step = .list

            return nil
        }
    }
}


// MARK: Workers

extension TodoWorkflow {

    struct TodoWorker: Worker {

        enum Output {

        }

        func run() -> SignalProducer<Output, NoError> {
            fatalError()
        }

        func isEquivalent(to otherWorker: TodoWorker) -> Bool {
            return true
        }

    }

}

// MARK: Rendering

extension TodoWorkflow {

    typealias Rendering = [BackStackScreen.Item]

    func render(state: TodoWorkflow.State, context: RenderContext<TodoWorkflow>) -> Rendering {

        let todoListItem = TodoListWorkflow(
            name: name,
            todos: state.todos)
            .mapOutput({ output -> ListAction in
                switch output {

                case .back:
                    return .back

                case .selectTodo(index: let index):
                    return .editTodo(index: index)

                case .newTodo:
                    return .newTodo
                }
            })
            .rendered(with: context)

        switch state.step {

        case .list:
            // Return only the list item.
            return [todoListItem]

        case .edit(index: let index):

            let todoEditItem = TodoEditWorkflow(
                initialTodo: state.todos[index])
                .mapOutput({ output -> EditAction in
                    switch output {
                    case .discard:
                        return .discardChanges

                    case .save(let updatedTodo):
                        return .saveChanges(index: index, todo: updatedTodo)
                    }
                })
                .rendered(with: context)

            // Return both the list item and edit.
            return [todoListItem, todoEditItem]
        }

    }
}
