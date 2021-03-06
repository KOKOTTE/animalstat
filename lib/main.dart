import 'package:flutter/services.dart';
import 'package:animalstat/app/login/login_screen.dart';
import 'package:animalstat/app/recurring_treatments/recurring_treatments_screen.dart';
import 'package:animalstat/app/splash/splash_screen.dart';
import 'package:animalstat/src/factories/repository_factory.dart';
import 'package:animalstat/src/ui/theming.dart';
import 'package:animalstat/src/bloc_providers.dart';
import 'package:animalstat/src/providers/multi_utility_provider.dart';
import 'package:animalstat/src/utility_providers.dart';
import 'package:animalstat/app/authentication/bloc/bloc.dart';
import 'package:bloc/bloc.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:animalstat_repository/animalstat_repository.dart';
import 'src/ui/theming.dart';

import 'src/animalstat_bloc_delegate.dart';

void main() {
  BlocSupervisor.delegate = AnimalstatBlocDelegate();

  // Set `enableInDevMode` to true to see reports while in debug mode
  // This is only to be used for confirming that reports are being
  // submitted as expected. It is not intended to be used for everyday
  // development.
  Crashlytics.instance.enableInDevMode = false;

  // Pass all uncaught errors from the framework to Crashlytics.
  FlutterError.onError = Crashlytics.instance.recordFlutterError;

  runApp(
    MultiUtilityProvider(
      providers: UtilityProviders.providers,
      child: RepositoryProvider<UserRepository>(
        create: (context) => FirestoreUserRepository(),
        child: MultiBlocProvider(
          providers: BlocProviders.providers,
          child: App(),
        ),
      ),
    ),
  );
}

class App extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);

        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: MaterialApp(
        theme: ThemeData(
          brightness: Brightness.light,
          fontFamily: 'SF Pro Text',
          primaryColor: kPrimaryColor,
          accentColor: kAccentColor,
          buttonColor: kButtonColor,
          backgroundColor: kBackgroundColor,
          scaffoldBackgroundColor: kBackgroundColor,
          dialogBackgroundColor: kWhite,
          primaryTextTheme: TextTheme(
            headline6: TextStyle(color: kWhite),
          ),
          textTheme: TextTheme(
            bodyText2: TextStyle(
              color: kDefaultTextColor,
            ),
          ),
          primaryIconTheme: const IconThemeData.fallback().copyWith(
            color: kAccentColor,
          ),
        ),
        home: BlocBuilder<AuthenticationBloc, AuthenticationState>(
            builder: (BuildContext context, AuthenticationState state) {
          if (state is Uninitialized) {
            return SplashScreen();
          }

          if (state is Unauthenticated) {
            return LoginScreen();
          }

          if (state is Authenticated) {
            return MultiRepositoryProvider(
              providers: [
                RepositoryProvider(
                  create: (context) =>
                      RepositoryFactory.createAnimalRepository(context),
                ),
                RepositoryProvider(
                  create: (context) =>
                      RepositoryFactory.createRecurringTreatmentsRepository(
                          context),
                ),
              ],
              child: RecurringTreatmentsScreen(),
            );
          }

          return Container();
        }),
      ),
    );
  }
}
