
import 'controllers/AddNewLocationController.dart';
import 'controllers/CommandController.dart';
import 'controllers/ToggleVoiceController.dart';
import 'exports/exports.dart';
import 'firebase_options.dart';
import 'observer/BlocObserver.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
   //initialize loaction permissions
      await initializeLocationPermissions();
  Bloc.observer = const AppObserver();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
// initialize notifications
  initializeNotifications();

 

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (x) => LocationController()),
        BlocProvider(create: (x) => VoiceTextController()),
        BlocProvider(create: (x) => AddNewLocationController()),
        BlocProvider(create: (x) => ToggleVoiceController()),
        BlocProvider(create: (x) => CommandController()),
        ChangeNotifierProvider(create: (x) => MainController()),
      ],
      child: MaterialApp(
        darkTheme: ThemeData.light(useMaterial3: true),
        themeMode: ThemeMode.system,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
              seedColor: const Color.fromARGB(14, 77, 78, 74)),
          useMaterial3: true,
        ),
        debugShowCheckedModeBanner: false,
        
        initialRoute: Routes.onBoarding,
        routes: Routes.routes,
      ),
    ),
  );
}
