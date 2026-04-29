import 'package:flutter/material.dart';

///Global variable for api source
const String baseUrl = "https://racheeta.pythonanywhere.com";
const String doctorsbaseUrl = "https://racheeta.pythonanywhere.com/doctor/";

/// Text Styles

/// AppBar Text Styles
const kAppBarDoctorsTextStyle =
    TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold);
const kAppBarDashboardTextStyle =
    TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold);
const kAppBarTextStyle =
    TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white);

/// AppBar Search Icons
const kAppBarDoctorSearchIcon = Icon(Icons.search, color: Colors.white);
const kAppBarPatientSearchIcon = Icon(Icons.search, color: Colors.white);

/// Dashboard Titles Text Style
const kDashboardTitlesTextStyle =
    TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16);

/// Button Text Styles
const kButtonTextStyle =
    TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white);
const kPatientButtonTextStyle =
    TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white);
const kReservationButtonTextStyle =
    TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white);

const kDoctorNameTextStyle = TextStyle(
  fontSize: 18,
  fontWeight: FontWeight.bold,
);
const kDoctorDescrpitionTextStyle = TextStyle(
  fontSize: 18,
  fontWeight: FontWeight.bold,
);
const kDoctorSearchTextStyle = TextStyle(fontSize: 20, color: Colors.white);
const kDoctorRatingTextStyle = TextStyle(
  fontSize: 14,
  color: Colors.grey,
);
const kHspDescriptionTextStyle = TextStyle(
  fontSize: 14,
  color: Colors.blue,
);
const kHspAvailbltyTextStyle = TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.w500,
);
const kStatusltyTextStyle = TextStyle(
  color: Colors.white,
  fontSize: 12,
  fontWeight: FontWeight.bold,
);
const kStatsDashboardTextStyle =
    TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20);

const kReservationLaberTextStyle =
    TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey);
const kFieldsTextStyle =
    TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue);

/// Miscellaneous Text Styles
const kAppointmentsHeaderStyleTextStyle = TextStyle(
  fontWeight: FontWeight.bold,
  fontSize: 16,
  color: Colors.black,
);
const kTablabelStyleTextStyle =
    TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white);
const kHeaderTextStyle = TextStyle(fontSize: 20, fontWeight: FontWeight.bold);
const kSplashTextStyle = TextStyle(color: Colors.white);

/// Doctor and Reservation Text Styles
const kDoctorCardsTextStyle = TextStyle(fontSize: 16);
const kDoctorCardsblueTextStyle =
    TextStyle(fontSize: 14, color: Colors.blue, fontWeight: FontWeight.bold);
const kDoctorProfileReservationPageTextStyle =
    TextStyle(fontSize: 16, color: Colors.grey);
const kDoctorProfileReservationNamePageTextStyle =
    TextStyle(fontSize: 18, fontWeight: FontWeight.bold);
const kHSPCardsblueTextStyle =
    TextStyle(fontSize: 14, fontWeight: FontWeight.w500);
const kReservationMSGTextStyle = TextStyle(
  color: Colors.white,
  fontSize: 24,
  fontWeight: FontWeight.bold,
);

/// Doctor Card Text Styles
const kDoctorCardNameTextStyle = TextStyle(
  color: Colors.blue,
  fontSize: 16,
  fontWeight: FontWeight.bold,
);
const kDoctorCardSpecialtyTextStyle = TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.w500,
);

/// Button Styles
/// Red Elevated Button Style
final ButtonStyle kRedElevatedButtonStyle = ElevatedButton.styleFrom(
  backgroundColor: Colors.red, // Red color
  padding: const EdgeInsets.symmetric(vertical: 15), // Vertical padding
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(10), // Rounded corners
  ),
);

/// Blue Elevated Button Style
final ButtonStyle kElevatedButtonStyle = ElevatedButton.styleFrom(
  backgroundColor: Colors.blue, // Blue color
  padding: const EdgeInsets.symmetric(vertical: 15), // Vertical padding
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(10), // Rounded corners
  ),
);

/// Red Patient Elevated Button Style
final ButtonStyle kRedPatientElevatedButtonStyle = ElevatedButton.styleFrom(
  backgroundColor: Colors.red, // Red color
  padding: const EdgeInsets.symmetric(vertical: 15), // Vertical padding
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(10), // Rounded corners
  ),
);

final ButtonStyle kSplashOutlinedButtonStyle = OutlinedButton.styleFrom(
  side: const BorderSide(color: Colors.blue),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(10),
  ),
);

/// Splash Screen Button Style
final ButtonStyle kSplashButtonStyle = ElevatedButton.styleFrom(
  backgroundColor: Colors.blue,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(10),
  ),
);

/// Icons

// Conversation Circle Avatar Icon
const kConversationCircleAvatar = CircleAvatar(
  backgroundColor: Colors.blueAccent,
  child: Icon(Icons.person, color: Colors.white),
);
// Text Styles

const TextStyle kJobBrowseButtonTextStyle = TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.bold,
  color: Colors.white,
);

const TextStyle kJobBrowseCardTitleTextStyle = TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.bold,
  color: Colors.blue,
);

const TextStyle kJobBrowseCardSubtitleTextStyle = TextStyle(
  fontSize: 14,
  color: Colors.black,
);

const TextStyle kEmptyListTextStyle = TextStyle(
  fontSize: 18,
  color: Colors.grey,
);
const TextStyle kTarteebTextStyle =
    TextStyle(fontSize: 20, fontWeight: FontWeight.bold);
// Button Styles
final ButtonStyle kBlueButtonStyle = ElevatedButton.styleFrom(
  backgroundColor: Colors.blue,
  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(10),
  ),
);

final ButtonStyle kRedButtonStyle = ElevatedButton.styleFrom(
  backgroundColor: Colors.red,
  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(10),
  ),
);

final ButtonStyle kSortButtonStyle = ElevatedButton.styleFrom(
  backgroundColor: Colors.blue,
  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(10),
  ),
);

final ButtonStyle kFilterButtonStyle = ElevatedButton.styleFrom(
  backgroundColor: Colors.blue,
  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(10),
  ),
);

const TextStyle kTakhsisTextStyle = TextStyle(
  fontSize: 18,
  fontWeight: FontWeight.bold,
  color: Colors.black54,
);


///offers
const TextStyle kOfferOldPriceTextStyle = TextStyle(
fontSize: 12,
color: Colors.grey,
decoration: TextDecoration.lineThrough,
);

const TextStyle kOfferDiscountTextStyle = TextStyle(
color: Colors.white,
fontSize: 12,
fontWeight: FontWeight.bold,
);
const TextStyle kOfferNameTextStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Color(0xFF007BFF),
);
const TextStyle kOfferReserveButtonTextStyle = TextStyle(
    fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold);

const EdgeInsets kSectionPadding = EdgeInsets.symmetric(
  horizontal: 12,
  vertical: 8,
);
const kDiscountBadgePadding = EdgeInsets.symmetric(horizontal: 8, vertical: 4);
final BorderRadius kBadgeBorderRadius = BorderRadius.circular(4);

final kDiscountBorderPadding =BoxDecoration(
  color: Colors.red,
  borderRadius: kBadgeBorderRadius,
);

final ButtonStyle kRedRoundedButtonStyle = ElevatedButton.styleFrom(
  backgroundColor: Colors.red,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(8),
  ),
);

const EdgeInsets kCardMargin   = EdgeInsets.all(12);
const double     kCardRadius   = 8.0;
const EdgeInsets kCardPadding  = EdgeInsets.all(12);