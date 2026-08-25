
# TS Driver

This project is a Flutter application utilizing Clean Architecture principles and GetX for state management. The directory structure is organized to maintain a clear separation of concerns and promote scalability.

## Project Structure

The project is divided into multiple modules, each representing a distinct feature or functionality within the application. Below is an overview of the main directories and their purpose:

### `app`

- **controllers**: Contains the controllers used throughout the entire app, managing the state and business logic with GetX.
- **core**: Contains core utilities and base classes used across the application.

### `modules`

Each module represents a specific feature or functionality of the application. They are further divided into subdirectories to adhere to Clean Architecture principles.

- **announcements**: Handles the announcement-related functionalities.
- **calling**: Handles the call functionalities.
- **chat**: Manages the chat functionalities.
- **chat_detail**: Handles the details of individual chat conversations.
- **documents**: Manages document-related functionalities.
- **forms**: Handles form-related functionalities.
- **forward_message**: Manages the forwarding of messages.
- **home**: Contains the home screen UI and related components.
- **inspection**: Manages inspection-related functionalities.
- **leave_management**: Manages leave applications and approvals.
- **login**: Handles the login process.
- **main_screen**: Contains the main screen UI and related components.
- **map**: Manages map-related functionalities.
- **notifications**: Handles notifications.
- **partner_forms_view**: Manages partner forms view functionalities.
- **partner_settlements**: Handles partner settlement functionalities.
- **profile**: Manages user profiles.
- **profile_add_accident_history**: Manages the addition of accident history to user profiles.
- **profile_details**: Manages the details of user profiles.
- **register**: Handles the registration process.
- **select_role**: Manages role selection during the registration or profile update process.
- **settings**: Contains settings-related functionalities.
- **settlements**: Manages settlements functionalities.
- **shipments**: Handles shipment-related functionalities.
- **signed_forms**: Manages signed forms.
- **splash**: Contains the splash screen UI.
- **truck_inspection**: Manages truck inspection functionalities.
- **vehicle_documents**: Manages vehicle document-related functionalities.
- **videos**: Handles video-related functionalities.
  ___

## Clean Architecture

Clean Architecture is a design pattern that promotes separation of concerns and improves the maintainability, scalability, and testability of the codebase. The main principles include:

- **Independence**: Each layer of the architecture is independent of the others, allowing for easier maintenance and testing.
- **Separation of Concerns**: Divides the application into distinct layers (data, domain, presentation) to keep the code organized and manageable.
- **Testability**: With clearly defined boundaries and dependencies, each layer can be tested in isolation, ensuring higher code quality.

### Layers of Clean Architecture

1. **Data Layer**: Responsible for data retrieval from various sources such as APIs, databases, or local storage.
2. **Domain Layer**: Contains the business logic and use cases. This layer is independent of any framework or technology.
3. **Presentation Layer**: Manages the UI components and user interactions with the help of state-management. This layer depends on the domain layer to execute use cases.

# State Management

This project uses **GetX** for state management. GetX is a powerful and lightweight solution that provides reactive state management, dependency injection, and route management.

### GetX Architecture

GetX is a powerful and lightweight Flutter framework that provides a range of features, including state management, dependency injection, and route management. It aims to simplify the development process while maintaining high performance and clean code architecture. The core components of GetX architecture include:

### 1. State Management

GetX provides a reactive state management solution that is simple and intuitive. It allows for efficient management of the application state with minimal boilerplate code.

#### Key Features

- **Reactive Programming**: Reactive variables (`Rx`) automatically update the UI when their state changes.
- **Simple Controllers**: Controllers in GetX manage the business logic and state of the application. They extend `GetxController` and can be easily initialized and used throughout the app.

### 2. Dependency Injection

GetX offers a dependency injection system that helps manage the lifecycle of objects, making it easier to manage dependencies across the application.

#### Key Features

- **Lazy Loading**: Dependencies are loaded only when they are needed, optimizing resource usage.
- **Lifecycle Management**: GetX automatically handles the lifecycle of dependencies, ensuring they are properly disposed of when no longer needed.

### 3. Route Management

GetX provides a powerful routing system that simplifies navigation within the application. It offers named routes, dynamic URL linking, and deep linking.

#### Key Features

- **Named Routes**: Easy-to-use named routes for navigation.
- **Dynamic URL**: Supports dynamic URLs for web applications, enabling deep linking and parameterized routes.
- **Middleware**: Allows for adding middleware to routes for authentication, logging, etc.

## GetX Architectural Components

### 1. **Bindings**

Bindings are used to manage the dependencies of your application. They ensure that controllers and other dependencies are initialized when the route is accessed.

### 2. **Controllers**

Controllers in GetX are used to manage the business logic and state of the application. They extend `GetxController` and use reactive variables to update the UI.

### 3. **Views**

Views are the UI components of the application. They use `Obx` or `GetBuilder` to listen to changes in the controller and update the UI accordingly.

### 4. **Routes**

Routes are defined to manage navigation within the application. GetX routes support named routes, dynamic parameters, and middlewares.

- For More Info:
[Getx]

```bash
https://github.com/jonataslaw/getx
```

## Getting Started

To get started with this project, ensure you have Flutter installed on your machine. Clone the repository and run the following commands:

```bash
flutter pub get
flutter run
