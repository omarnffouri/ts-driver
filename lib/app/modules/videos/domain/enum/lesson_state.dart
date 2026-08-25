/// Lifecycle of a single lesson in the sequential training course. Gating is
/// positional — a lesson unlocks only once the previous one is completed.
enum LessonState { completed, inProgress, available, locked }

extension LessonStateX on LessonState {
  bool get isCompleted => this == LessonState.completed;
  bool get isInProgress => this == LessonState.inProgress;
  bool get isAvailable => this == LessonState.available;
  bool get isLocked => this == LessonState.locked;
}
