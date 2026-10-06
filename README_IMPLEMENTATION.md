# Bike Rider App Implementation Details

## Overview
This application is a Flutter mobile app designed to help users track their bike rides, manage groups of riders, share ride photos, and log food expenses. The application captures geographic coordinates when rides start or photos are taken, and displays a comprehensive summary of these details.

## Project Structure
The app utilizes a standard structural pattern:
- **`lib/models/`**: Contains the data structures.
- **`lib/providers/`**: Handles the app state using the `provider` package.
- **`lib/screens/`**: Holds all the UI definitions for the app.
- **`test/`**: Contains widget tests to verify user flows.

## Data Models
Located in `lib/models/models.dart`:
- **`Rider`**: Represents an individual rider.
- **`RideGroup`**: A grouping of riders.
- **`Photo`**: A photo captured during a ride, includes path and coordinates.
- **`Expense`**: A food expense incurred during the ride.
- **`Ride`**: The main entity containing a date, name, associated group, lists of photos and expenses, and starting coordinates.

## State Management
Located in `lib/providers/`:
- **`AuthProvider`**: Manages basic user authentication state.
- **`RideProvider`**: Manages the lists of rides, groups, and riders. It provides methods to add new entries, modify groups, and append photos/expenses to specific rides.

## UI Screens
Located in `lib/screens/`:
1. **`LoginScreen`**: Simple mock authentication interface.
2. **`HomeScreen`**: Displays a list of all logged rides. It serves as the primary navigation point to other screens.
3. **`ManageGroupsScreen`**: Allows users to create new groups and populate them with riders.
4. **`RideDetailsScreen`**: Provides a summary view of a specific ride. It calculates total expenses, displays the start coordinates, lists expenses, and shows a grid of captured photos.

## Plugins Utilized
The app relies on several external plugins:
- **`provider`**: For predictable state management.
- **`uuid`**: To generate unique IDs for entities.
- **`image_picker`**: Enables access to the device camera to take ride photos.
- **`geolocator`**: Fetches latitude and longitude to accurately record where rides start and photos are taken.

### Native Configurations
- **iOS (`Info.plist`)**: Requires descriptions for `NSCameraUsageDescription`, `NSPhotoLibraryUsageDescription`, and `NSLocationWhenInUseUsageDescription`.
- **Android (`AndroidManifest.xml`)**: Requires `ACCESS_FINE_LOCATION` and `ACCESS_COARSE_LOCATION` permissions.

## Testing
Located in `test/app_test.dart`:
The application includes a comprehensive widget test simulating the standard user flow:
1. Logging into the app.
2. Navigating to the group management screen.
3. Creating a new group ("Mountain Bikers") and adding a rider ("Alice").
4. Starting a new ride ("Weekend Trail").
5. Accessing the ride details and adding a new expense ("Coffee" for $5.50).
6. Verifying the correct update of the total expenses summary.