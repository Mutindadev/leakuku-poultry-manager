// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/foundation.dart';
// import 'package:hive/hive.dart';
// import 'package:leakuku/features/auth/data/data_sources/remote_implementation.dart';
// import 'package:leakuku/features/auth/data/repositories/auth_implementation.dart';
// import 'package:leakuku/features/auth/domain/use_case/sign_out.dart';
// import 'package:leakuku/features/user/data/data_sources/remote_implementation.dart';
// import 'package:leakuku/features/user/data/models/user.dart';
// import 'package:leakuku/features/user/data/repositories/user_implementation.dart';
// import 'package:leakuku/features/user/domain/use_case/read.dart';

// enum AuthenticationState { unknown, authenticated, unauthenticated }

// enum RegistrationState { unknown, incomplete, complete }

// class UserProvider extends ChangeNotifier {
//   // Hive box for caching
//   static const String _userBoxName = 'user_cache';
//   static const String _currentUserKey = 'current_user';
//   Box<UserModel>? _userBox;

//   // Dependencies
//   SignOutUseCase _signOutUseCase = SignOutUseCase(
//     repository: AuthRepositoryImplementation(
//       remoteDataSource: AuthRemoteDataSourceImplementation(),
//     ),
//   );

//   ReadUserUseCase _readUserUseCase = ReadUserUseCase(
//     repository: UserRepositoryImplementation(
//       remoteDataSource: UserRemoteDataSourseImlementation(),
//     ),
//   );

//   // State variables
//   User? _firebaseUser;
//   UserModel? _userModel;
//   AuthenticationState _authState = AuthenticationState.unknown;
//   RegistrationState _registrationState = RegistrationState.unknown;
//   bool _isLoading = false;
//   String? _errorMessage;
//   ProfileProvider? _profileProvider;

//   // Constructor
//   UserProvider() {
//     _initializeHive();
//     _listenToAuthChanges();
//   }

//   void setDependencies({required ProfileProvider profileProvider}) {
//     _profileProvider = profileProvider;
//   }

//   // Initialize Hive box
//   Future<void> _initializeHive() async {
//     try {
//       _userBox = await Hive.openBox<UserModel>(_userBoxName);

//       // Load cached user data if available
//       final cachedUser = _userBox?.get(_currentUserKey);
//       if (cachedUser != null) {
//         _userModel = cachedUser;

//         // Check if cached user profile is complete
//         if (_isProfileComplete(cachedUser)) {
//           _registrationState = RegistrationState.complete;
//         } else {
//           _registrationState = RegistrationState.incomplete;
//         }

//         notifyListeners();
//       }
//     } catch (e) {
//       debugPrint('Error initializing Hive: $e');
//     }
//   }

//   // Cache user data to Hive
//   Future<void> _cacheUserData(UserModel user) async {
//     try {
//       await _userBox?.put(_currentUserKey, user);
//     } catch (e) {
//       debugPrint('Error caching user data: $e');
//     }
//   }

//   // Remove cached user data
//   Future<void> _clearCachedUserData() async {
//     try {
//       await _userBox?.delete(_currentUserKey);
//     } catch (e) {
//       debugPrint('Error clearing cached user data: $e');
//     }
//   }

//   // Getters
//   User? get firebaseUser => _firebaseUser;
//   UserModel? get user => _userModel;
//   AuthenticationState get authState => _authState;
//   RegistrationState get registrationState => _registrationState;
//   bool get isLoading => _isLoading;
//   String? get errorMessage => _errorMessage;

//   // Computed getters
//   bool get isLoggedIn => _authState == AuthenticationState.authenticated;
//   bool get isRegistrationComplete =>
//       _registrationState == RegistrationState.complete;
//   bool get isAnonymous => _firebaseUser?.isAnonymous ?? false;
//   String get userId => _firebaseUser?.uid ?? '';
//   String get userEmail => _firebaseUser?.email ?? '';

//   // Listen to Firebase auth state changes
//   void _listenToAuthChanges() {
//     FirebaseAuth.instance.authStateChanges().listen((User? user) {
//       _firebaseUser = user;

//       if (user == null) {
//         _handleSignOut();
//       } else {
//         handleSignIn(user);
//       }

//       notifyListeners();
//     });
//   }

//   // Handle user sign in
//   Future<void> handleSignIn(User user) async {
//     _authState = AuthenticationState.authenticated;
//     _firebaseUser = user;

//     _profileProvider?.checkProfileSetupStatus();
//     // First check cached data for this user
//     final cachedUser = _userBox?.get(_currentUserKey);
//     if (cachedUser != null && cachedUser.uid == user.uid) {
//       _userModel = cachedUser;
//       _registrationState = _isProfileComplete(cachedUser)
//           ? RegistrationState.complete
//           : RegistrationState.incomplete;
//       notifyListeners();

//       // Refresh data in background
//       _refreshUserDataInBackground(user.uid);
//     } else {
//       // No cached data or different user, fetch fresh data
//       await _checkRegistrationStatus(user.uid);
//     }
//   }

//   // Handle user sign out
//   void _handleSignOut() {
//     _authState = AuthenticationState.unauthenticated;
//     _registrationState = RegistrationState.unknown;
//     _firebaseUser = null;
//     _userModel = null;
//     _errorMessage = null;

//     // Clear cached data
//     _clearCachedUserData();
//   }

//   // Refresh user data in background without showing loading
//   Future<void> _refreshUserDataInBackground(String userId) async {
//     try {
//       final result = await _readUserUseCase(userId);

//       result.fold(
//         (failure) {
//           // Keep existing cached data if fetch fails
//           debugPrint('Background refresh failed: ${failure.message}');
//         },
//         (user) {
//           // Update with fresh data
//           _userModel = user;

//           if (_isProfileComplete(user)) {
//             _registrationState = RegistrationState.complete;
//           } else {
//             _registrationState = RegistrationState.incomplete;
//           }

//           // Cache the fresh data
//           _cacheUserData(user);
//           _errorMessage = null;
//           notifyListeners();
//         },
//       );
//     } catch (e) {
//       debugPrint('Background refresh error: $e');
//     }
//   }

//   // Check if user registration is complete
//   Future<void> _checkRegistrationStatus(String userId) async {
//     try {
//       _setLoading(true);

//       final result = await _readUserUseCase(userId);

//       result.fold(
//         (failure) {
//           // User doesn't exist in Firestore - registration incomplete
//           _registrationState = RegistrationState.incomplete;
//           _userModel = null;
//           _errorMessage = failure.message;

//           // Clear any stale cached data
//           _clearCachedUserData();
//         },
//         (user) {
//           // User exists - check if profile is complete
//           _userModel = user;

//           if (_isProfileComplete(user)) {
//             _registrationState = RegistrationState.complete;
//           } else {
//             _registrationState = RegistrationState.incomplete;
//           }

//           _errorMessage = null;

//           // Cache the user data
//           _cacheUserData(user);
//         },
//       );
//     } catch (e) {
//       _registrationState = RegistrationState.incomplete;
//       _errorMessage = 'Error checking registration status: $e';
//     } finally {
//       _setLoading(false);
//     }
//   }

//   // Check if user profile has all required fields
//   bool _isProfileComplete(UserModel user) {
//     return user.email.isNotEmpty && user.phonenumber.isNotEmpty;
//     // Add more conditions as needed (profile pic, role, etc.)
//   }

//   // Update user model after successful operations
//   void updateUserModel(UserModel user) {
//     _userModel = user;
//     _registrationState = _isProfileComplete(user)
//         ? RegistrationState.complete
//         : RegistrationState.incomplete;
//     _errorMessage = null;

//     // Cache the updated user data
//     _cacheUserData(user);
//     notifyListeners();
//   }

//   // Complete registration
//   void completeRegistration(UserModel user) {
//     _userModel = user;
//     _registrationState = RegistrationState.complete;
//     _errorMessage = null;

//     // Cache the complete user data
//     _cacheUserData(user);
//     notifyListeners();
//   }

//   // Sign out user
//   Future<void> signOut() async {
//     try {
//       _setLoading(true);

//       final result = await _signOutUseCase().whenComplete(() {
//         _handleSignOut();
//       });

//       result.fold(
//         (failure) {
//           _errorMessage = failure.message;
//         },
//         (_) {
//           // Sign out successful - auth listener will handle state update
//           _errorMessage = null;
//         },
//       );
//     } catch (e) {
//       _errorMessage = 'Error signing out: $e';
//     } finally {
//       _setLoading(false);
//     }
//   }

//   // Refresh user data (force refresh from server)
//   Future<void> refreshUserData() async {
//     if (_firebaseUser != null) {
//       await _checkRegistrationStatus(_firebaseUser!.uid);
//     }
//   }

//   // Get cached user data without network call
//   UserModel? getCachedUser() {
//     return _userBox?.get(_currentUserKey);
//   }

//   // Check if user data is cached
//   bool get hasCachedUserData => _userBox?.containsKey(_currentUserKey) ?? false;

//   // Clear all cached data (useful for debugging or reset)
//   Future<void> clearAllCache() async {
//     try {
//       await _userBox?.clear();
//       _userModel = null;
//       notifyListeners();
//     } catch (e) {
//       debugPrint('Error clearing all cache: $e');
//     }
//   }

//   // Clear error message
//   void clearError() {
//     _errorMessage = null;
//     notifyListeners();
//   }

//   // Set loading state
//   void _setLoading(bool loading) {
//     _isLoading = loading;
//     notifyListeners();
//   }

//   // Force authentication state (useful for testing or special cases)
//   void forceAuthState(AuthenticationState state) {
//     _authState = state;
//     notifyListeners();
//   }

//   // Force registration state (useful for testing or special cases)
//   void forceRegistrationState(RegistrationState state) {
//     _registrationState = state;
//     notifyListeners();
//   }

//   @override
//   void dispose() {
//     _userBox?.close();
//     super.dispose();
//   }
// }
