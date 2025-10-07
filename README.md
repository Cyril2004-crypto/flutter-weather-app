# Weather App - 4 Programming Themes Implementation

A Flutter weather application that demonstrates four key programming themes:

##  1. Version Control (Git + GitHub)
- Initialized Git repository with proper commit tracking
- Features are tracked with individual commits
- Ready for GitHub remote repository setup

##  2. Event-Driven Programming
- **Search Button**: Triggers weather API calls when clicked
- **Text Input**: Supports search on Enter key press
- **Login Form**: Validates and processes login events
- **Logout Button**: Handles session management

##  3. Interoperability (OpenWeatherMap API)
- Real-time weather data from OpenWeatherMap API
- HTTP requests with proper error handling
- JSON data parsing and display
- Supports city name and coordinate-based searches

##  4. Virtual Identity
- **Login System**: Simple authentication with local storage
- **User Preferences**: Saves preferred city and username
- **Session Management**: Remembers login state between app launches
- **Personalization**: Welcomes user by name

##  Getting Started

### Prerequisites
- Flutter SDK installed
- Android Studio or VS Code with Flutter extensions
- OpenWeatherMap API key (free at openweathermap.org)

### Setup Instructions

1. **Clone the repository**
   `ash
   git clone <your-repo-url>
   cd weather_app
   `

2. **Install dependencies**
   `ash
   flutter pub get
   `

3. **Get OpenWeatherMap API Key**
   - Visit [OpenWeatherMap](https://openweathermap.org/api)
   - Sign up for a free account
   - Generate an API key

4. **Configure API Key**
   - Open lib/services/weather_service.dart
   - Replace YOUR_API_KEY_HERE with your actual API key

5. **Run the app**
   `ash
   flutter run
   `

##  Project Structure

`
lib/
 main.dart              # App entry point with Firebase setup
 models/
    weather_model.dart # Weather data model with JSON serialization
    weather_model.g.dart # Generated JSON serialization code
 services/
    weather_service.dart # API service for weather data
 screens/
     login_screen.dart   # Login screen with virtual identity
     weather_screen.dart # Main weather display screen
`

##  Features

### Authentication & User Management
- Simple login form with validation
- Username and password storage
- Session persistence
- Logout functionality

### Weather Features
- Search weather by city name
- Real-time weather data display
- Detailed weather information:
  - Current temperature
  - "Feels like" temperature
  - Min/Max temperatures
  - Humidity percentage
  - Atmospheric pressure
  - Wind speed and direction
  - Cloud coverage
- Weather condition descriptions

### User Experience
- Beautiful, responsive UI design
- Loading indicators during API calls
- Error handling and user feedback
- Preferred city saving and auto-loading
- Gradient weather cards
- Material Design components

##  Demo Login
- Username: Any text (e.g., "demo")
- Password: Any text with 4+ characters (e.g., "1234")

##  Technologies Used

- **Flutter**: Cross-platform mobile framework
- **Dart**: Programming language
- **HTTP Package**: For API calls
- **Shared Preferences**: Local data storage
- **JSON Annotation**: For data serialization
- **Material Design**: UI components

##  Theme Implementation Details

### 1. Version Control
- All changes tracked in Git commits
- Commit messages follow conventional format
- Ready for collaborative development

### 2. Event-Driven Programming
- Search button onClick events
- TextField onSubmitted events
- Login form validation events
- Navigation events between screens

### 3. Interoperability
- REST API integration with OpenWeatherMap
- HTTP GET requests with proper headers
- JSON response parsing
- Error handling for network issues

### 4. Virtual Identity
- User authentication simulation
- Local storage of user preferences
- Session state management
- Personalized user experience

##  Contributing

1. Fork the repository
2. Create a feature branch (git checkout -b feature/amazing-feature)
3. Commit your changes (git commit -m 'Add amazing feature')
4. Push to the branch (git push origin feature/amazing-feature)
5. Open a Pull Request

##  License

This project is licensed under the MIT License - see the LICENSE file for details.

##  Acknowledgments

- OpenWeatherMap for providing free weather API
- Flutter team for the amazing framework
- Material Design for UI inspiration
