# Citrus Admin iOS

iOS admin dashboard for the Citrus Enterprise Receipt Intelligence Platform.

## Features

### 1. Dashboard Analytics
- Real-time metrics and KPIs
- Receipt status breakdown
- Top spending categories
- Recent activity feed
- Visual data representation

### 2. User Management
- View and search users
- Filter by role (Admin, Manager, User, Viewer)
- User details with permissions
- Activate/deactivate users
- Add new users with role-based permissions

### 3. Receipt Review
- Browse and search receipts
- Filter by status (Pending, Approved, Rejected, Flagged)
- Filter by category (Meals, Travel, Office, Entertainment, Equipment)
- Detailed receipt view with line items
- Approve, reject, or flag receipts
- Track review history

### 4. Alerts & Notifications
- Real-time system alerts
- Filter by severity (Info, Warning, Error, Critical)
- Action-required indicators
- Alert resolution tracking
- Unread notification badges

## Architecture

### Tech Stack
- **Language**: Swift
- **UI Framework**: SwiftUI
- **Reactive Programming**: Combine
- **Architecture**: MVVM (Model-View-ViewModel)

### Project Structure
```
CitrusAdmin/
├── Models/              # Data models
│   ├── User.swift
│   ├── Receipt.swift
│   ├── Analytics.swift
│   └── Alert.swift
├── ViewModels/          # Business logic with Combine
│   ├── UserViewModel.swift
│   ├── ReceiptViewModel.swift
│   ├── AnalyticsViewModel.swift
│   └── AlertViewModel.swift
├── Views/               # SwiftUI views
│   ├── ContentView.swift
│   ├── DashboardView.swift
│   ├── UserManagementView.swift
│   ├── ReceiptReviewView.swift
│   └── AlertsView.swift
├── Services/            # Data and API services
│   └── DataService.swift
└── Utilities/           # Helper extensions
    └── Extensions.swift
```

## Key Components

### Models
- **User**: User accounts with role-based permissions
- **Receipt**: Receipt data with categorization and status
- **Analytics**: Dashboard metrics and summary data
- **Alert**: System notifications and warnings

### ViewModels
All ViewModels use Combine for reactive state management:
- Published properties for UI binding
- Debounced search and filtering
- Automatic data refresh
- Clean separation of concerns

### Views
SwiftUI views following iOS design patterns:
- Native iOS components
- Adaptive layouts
- Dark mode support
- Accessibility features

## Permissions System

### Roles
1. **Admin**: Full access to all features
2. **Manager**: User view, receipt review, analytics, alerts
3. **User**: Receipt view, analytics, alerts
4. **Viewer**: Receipt view, analytics (read-only)

## Data Flow

1. **ViewModels** manage application state
2. **Combine** publishers handle reactive updates
3. **DataService** provides data abstraction layer
4. **Views** observe ViewModel published properties
5. UI automatically updates when state changes

## Future Enhancements

- [ ] API integration with backend
- [ ] Push notifications
- [ ] Offline mode with Core Data
- [ ] Export functionality (CSV, PDF)
- [ ] Advanced filtering and sorting
- [ ] Charts and visualizations
- [ ] Biometric authentication
- [ ] Multi-language support

## Requirements

- iOS 15.0+
- Xcode 13.0+
- Swift 5.5+

## Development

### Mock Data
The app currently uses mock data for demonstration. All ViewModels load sample data on initialization.

### API Integration
To connect to a backend API, implement the methods in `DataService.swift` and update ViewModels to use the service instead of mock data.

## License

Part of the Citrus Enterprise Receipt Intelligence Platform.
