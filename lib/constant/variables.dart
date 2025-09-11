import 'package:flutter_dotenv/flutter_dotenv.dart';

class Variables {
  // App Configuration
  static String get appName => dotenv.env['APP_NAME'] ?? 'BMMB Pajak Gadai-i';
  static String get appDescription => dotenv.env['APP_DESCRIPTION'] ?? 'Muamalat Pajak Gadai Islam (Ar-Rahnu)';
  static String get appVersion => dotenv.env['APP_VERSION'] ?? '2.0.2+10014';

  // API URLs
  static String get baseUrl => dotenv.env['BASE_URL'] ?? 'https://arrahnuauction.stg.muamalat.com.my';
  static String get mainUrl => dotenv.env['MAIN_URL'] ?? 'https://muamalat.com.my';
  static String get url => dotenv.env['URL_PATH'] ?? 'financing/personal/ar-rahnu/ar-rahnu-islamic-pawn-broking-tawarruq';

  // API Endpoints
  static String get apiTokenEndpoint => dotenv.env['API_TOKEN_ENDPOINT'] ?? '/api/token/';
  static String get apiTokenRefreshEndpoint => dotenv.env['API_TOKEN_REFRESH_ENDPOINT'] ?? '/api/token/refresh/';
  static String get apiProfileEndpoint => dotenv.env['API_PROFILE_ENDPOINT'] ?? '/api/profile/';
  static String get apiBidListEndpoint => dotenv.env['API_BID_LIST_ENDPOINT'] ?? '/api/bid_list/';
  static String get apiBidCreateEndpoint => dotenv.env['API_BID_CREATE_ENDPOINT'] ?? '/api/bid_create/';
  static String get apiGoldPriceEndpoint => dotenv.env['API_GOLD_PRICE_ENDPOINT'] ?? '/api/gold_price/';
  static String get apiPagesEndpoint => dotenv.env['API_PAGES_ENDPOINT'] ?? '/api/v2/pages/';

  // Web URLs
  static String get signupUrl => dotenv.env['SIGNUP_URL'] ?? '/signup/';
  static String get passwordResetUrl => dotenv.env['PASSWORD_RESET_URL'] ?? '/password/reset/';
  static String get calculatorUrl => dotenv.env['CALCULATOR_URL'] ?? 'ar-rahnu-calculator';

  // App Text
  static String get text1 => dotenv.env['APP_INTRO_TEXT'] ?? "Introduction Islamic Pawn Broking Tawarruq (Muamalat Ar-Rahnu) Mobile App";
  static String get text2 => dotenv.env['APP_SUBTITLE_TEXT'] ?? "Your One-Stop Convenient Digital Platform";
  static String get systemTitle => dotenv.env['SYSTEM_TITLE'] ?? 'Sistem e-Lelong (Pajak Gadai-i)';
  static String get auctionSystemTitle => dotenv.env['AUCTION_SYSTEM_TITLE'] ?? 'Ar-Rahnu Online Auction System';
  static String get biddingStartText => dotenv.env['BIDDING_START_TEXT'] ?? 'Bidding Session Start at:';
  static String get biddingEndText => dotenv.env['BIDDING_END_TEXT'] ?? 'Bidding Session End at:';
  static String get goodStatusText => dotenv.env['GOOD_STATUS_TEXT'] ?? 'Good!';
  static String get waitingBiddingText => dotenv.env['WAITING_BIDDING_TEXT'] ?? 'Waiting for Bidding!';
  static String get biddingProgressText => dotenv.env['BIDDING_PROGRESS_TEXT'] ?? 'Bidding on Progress!';
  static String get biddingDoneText => dotenv.env['BIDDING_DONE_TEXT'] ?? 'Already Done Bidding!';
  static String get pleaseWaitText => dotenv.env['PLEASE_WAIT_TEXT'] ?? 'Please wait';
  static String get failedLoadDataText => dotenv.env['FAILED_LOAD_DATA_TEXT'] ?? 'Failed to load data!';
  static String get failedLoadBidInfoText => dotenv.env['FAILED_LOAD_BID_INFO_TEXT'] ?? 'Failed to load Bid Info';
  static String get failedLoadPosterInfoText => dotenv.env['FAILED_LOAD_POSTER_INFO_TEXT'] ?? 'Failed to load Poster Info';
  static String get successTitle => dotenv.env['SUCCESS_TITLE'] ?? 'Success';
  static String get profileUpdatedText => dotenv.env['PROFILE_UPDATED_TEXT'] ?? 'Profile Updated Successfully';
  static String get failedTitle => dotenv.env['FAILED_TITLE'] ?? 'Failed';
  static String get profileUpdateFailedText => dotenv.env['PROFILE_UPDATE_FAILED_TEXT'] ?? 'Failed to update profile';
  static String get confirmSignOutTitle => dotenv.env['CONFIRM_SIGN_OUT_TITLE'] ?? 'Confirm Sign Out';
  static String get signOutConfirmText => dotenv.env['SIGN_OUT_CONFIRM_TEXT'] ?? 'Are you sure to sign out?';
  static String get okText => dotenv.env['OK_TEXT'] ?? 'OK';
  static String get calculatorTitle => dotenv.env['CALCULATOR_TITLE'] ?? 'ArRahnu Calculator';
  
  // Image URLs
  static String get defaultAvatarUrl => dotenv.env['DEFAULT_AVATAR_URL'] ?? 'https://cdn1.iconfinder.com/data/icons/user-pictures/100/unknown-514.png';
  static String get promotionImage1 => dotenv.env['PROMOTION_IMAGE_1'] ?? 'https://arrahnuauction.muamalat.com.my/media/announcement/Ar_Rahnu_Promotion_Deal_8.99-01.jpg';
  static String get promotionImage2 => dotenv.env['PROMOTION_IMAGE_2'] ?? 'https://arrahnuauction.muamalat.com.my/media/announcement/Ar_Rahnu_Promotion_Deal_0.75-03.jpg';

  // Asset Paths
  static String get assetProductFeatures => dotenv.env['ASSET_PRODUCT_FEATURES'] ?? 'assets/images/product_features.png';
  static String get assetGoldPrice => dotenv.env['ASSET_GOLD_PRICE'] ?? 'assets/images/gold_price.png';
  static String get assetCalculator => dotenv.env['ASSET_CALCULATOR'] ?? 'assets/images/calculator.png';
  static String get assetAuction => dotenv.env['ASSET_AUCTION'] ?? 'assets/images/auction.png';

  // Campaign Data
  static String get campaignTitle1 => dotenv.env['CAMPAIGN_TITLE_1'] ?? 'Ar-Rahnu, Islamic Pawn Broking (Tawarruq)';
  static String get campaignDescription1 => dotenv.env['CAMPAIGN_DESCRIPTION_1'] ?? 'Benefits of Ar-Rahnu:\r\n\r\n1) Fully-Shariah compliant product\r\n2) Free from Riba\' (usury) and Gharar (uncertainty)\r\n3) Fixed Profit Rate on the financing amount\r\n4) No early redemption charges\r\n5) High margin of advance\r\n6) Fast, easy and secure\r\n7) Gold cleaning service\r\n8) Improve customer experience by providing convenient online Ar-Rahnu revaluation transaction without present at BMMB premise.\r\n9) Accept gold bullion (bar/coins/dinar) for pawning without opening the seal (15 selected branches only).';
  static String get campaignDatetimeCreated1 => dotenv.env['CAMPAIGN_DATETIME_CREATED_1'] ?? '2023-12-05T17:23:00.258276+08:00';
  static String get campaignDatetimeModified1 => dotenv.env['CAMPAIGN_DATETIME_MODIFIED_1'] ?? '2023-12-05T22:53:03.033911+08:00';
  static String get campaignDatetimeCreated2 => dotenv.env['CAMPAIGN_DATETIME_CREATED_2'] ?? '2023-12-05T17:23:34.395019+08:00';
  static String get campaignDatetimeModified2 => dotenv.env['CAMPAIGN_DATETIME_MODIFIED_2'] ?? '2023-12-05T17:33:48.750587+08:00';
  static int get campaignStaffId => int.tryParse(dotenv.env['CAMPAIGN_STAFF_ID'] ?? '1981') ?? 1981;
  static int get campaignCreatedBy => int.tryParse(dotenv.env['CAMPAIGN_CREATED_BY'] ?? '1981') ?? 1981;
  static int get campaignUpdatedBy => int.tryParse(dotenv.env['CAMPAIGN_UPDATED_BY'] ?? '1981') ?? 1981;
}
