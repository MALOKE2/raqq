class AppConstants {
  static const String appName = "الراقي العراقي";
  static const String devPasswordDefault = "mhnd1978";
  static const String prefKeyIsDevLoggedIn = "is_dev_logged_in";
  static const String prefKeyDevPassword = "dev_password";
  static const String prefKeyRuqyahPhone = "ruqyah_booking_phone";

  // ===== تواصل =====
  static const List<String> contactNumbers = [
    "+9647700000000",
    "+9647800000000",
  ];
  static const String whatsapp = "https://wa.me/9647700000000";
  static const String facebook = "https://www.facebook.com/alraqyiraqi";
  static const String instagram = "https://www.instagram.com/alraqyiraqi";
  static const String twitter = "https://x.com/alraqyiraqi";
  static const String tiktok = "https://www.tiktok.com/@alraqyiraqi";
  static const String website = "https://www.alraqyiraqi.iq";
  static const String email = "info@alraqyiraqi.iq";
  static const String ruqyahPhone = "+9647700000000";

  // ===== روابط تواصل معنا الافتراضية =====
  static const List<Map<String, String>> defaultContactLinks = [
    {
      'label': 'اتصال مباشر',
      'url': 'tel:+9647904532882',
      'icon': 'Icons.phone',
    },
    {
      'label': 'مراسلة واتساب',
      'url': 'https://wa.me/7904532882',
      'icon': 'Icons.chat',
    },
    {
      'label': 'يوتيوب الراقي',
      'url': 'https://youtube.com/@mohanednajde?si=RCbWhzkjl7a-I3xD',
      'icon': 'Icons.youtube',
    },
    {
      'label': 'فيسبوك',
      'url': 'https://www.facebook.com/share/18gfW23Jvj/',
      'icon': 'Icons.facebook',
    },
    {
      'label': 'إنستغرام',
      'url': 'https://www.instagram.com/mohanednajde?mdxt=MTQ4cnJ5MzB5bmV1eA==',
      'icon': 'Icons.camera_alt',
    },
  ];

  // ===== اختصارات الرقية المسموعة الافتراضية (مثبتة داخل التطبيق) =====
  static const List<Map<String, String>> defaultAudioShortcuts = [
    {
      'title': 'رقية العين',
      'url': 'https://youtu.be/QG5wqoOQ_wg?si=P7-H9ZLnBcDD5cYQ',
    },
    {
      'title': 'ايات السكينة',
      'url': 'https://youtu.be/mBWmMHrYwJM?si=SUtfRRf_vHTgJJFx',
    },
    {
      'title': 'رقية المس العاشق',
      'url': 'https://youtu.be/Fr1mEko_rko?si=7N0x0E9-kY5YKj7L',
    },
    {
      'title': 'رقية ابطال السحر',
      'url': 'https://youtu.be/CgZGmGyP2Z0?si=zGXNouJHLgRrRxJV',
    },
    {
      'title': 'ايات الحرق والعذاب',
      'url': 'https://youtu.be/a02F9oOntuo?si=mILF41k6rtngyLhJ',
    },
    {
      'title': 'رقية ذم الوسوسة',
      'url': 'https://youtu.be/IppqEtdWuOU?si=NWvhXWsjNQZkuMMv',
    },
    {
      'title': 'رقية ايات التثبيت',
      'url': 'https://youtu.be/xQ4hE9tVDCo?si=9GMsrGO7X0sUFv5U',
    },
    {
      'title': 'دعاء على السحرة',
      'url': 'https://youtu.be/qEY_H3kKi80?si=3zmiMO-37vx6N-D6',
    },
  ];

  // ===== PDF من معلومات_داخلية =====
  static const String pdfAbout = "assets/pdf/about/about_raqi.pdf";

  // ===== كتب افتراضية تم استخراجها من ملف (ملف الكتب) =====
  static const List<Map<String, String>> defaultBooks = [
    {
      "title": "أجرة الراقي",
      "author": "الراقي العراقي",
      "type": "مؤلفات الراقي",
      "description": "كتاب يتحدث عن أحكام أجرة الراقي ومشروعية أخذ الأجر على الرقية الشرعية.",
      "keywords": "أجرة, الراقي, الرقية, أجر, شرعية",
      "pdf": "assets/pdf/books/ajra_al_raqi.pdf",
      "cover": "assets/book_covers/cover_1794579251374.jpg",
    },
    {
      "title": "أکام المرجان",
      "author": "المؤلف",
      "type": "مؤلفات الراقي",
      "description": "كتاب في العلوم الشرعية والرقية، من مؤلفات المكتبة.",
      "keywords": "المرجان, علوم, رقية",
      "pdf": "assets/pdf/books/akam_al_marjan.pdf",
      "cover": "assets/book_covers/cover_1794579090362.jpg",
    },
    {
      "title": "الأذكار العاصمة",
      "author": "المؤلف",
      "type": "كتب أخرى",
      "description": "مجموعة من الأذكار الجامعة للعاصمة والحفظ بإذن الله.",
      "keywords": "أذكار, عاصمة, حفظ",
      "pdf": "assets/pdf/books/adhkar_asima.pdf",
      "cover": "assets/book_covers/cover_1794579113782.jpg",
    },
    {
      "title": "الأربعون النبوية",
      "author": "النووي",
      "type": "كتب أخرى",
      "description": "أربعون حديثًا نبويًا مختارة للتدبر والعمل.",
      "keywords": "أربعون, نبوية, حديث",
      "pdf": "assets/pdf/books/arbaon_nabawiya.pdf",
      "cover": "assets/book_covers/cover_1794579235911.jpg",
    },
    {
      "title": "الصارم البتار",
      "author": "ابن تيمية",
      "type": "كتب أخرى",
      "description": "كتاب في الرد على المسيئين للسنة النبوية.",
      "keywords": "صارم, بتار, ابن تيمية",
      "pdf": "assets/pdf/books/sarram_battar.pdf",
      "cover": "assets/book_covers/cover_1794579123959.jpg",
    },
    {
      "title": "الطب الروحاني لابن الجوزي",
      "author": "ابن الجوزي",
      "type": "كتب أخرى",
      "description": "كتاب في العلاج الروحاني والشرعي.",
      "keywords": "طب, روحاني, ابن الجوزي",
      "pdf": "assets/pdf/books/tib_ruhani.pdf",
      "cover": "assets/book_covers/cover_1794579146390.jpg",
    },
    {
      "title": "لقط المرجان في أحكام الجان",
      "author": "السيوطي",
      "type": "كتب أخرى",
      "description": "كتاب في أحكام الجان والجن من تأليف السيوطي.",
      "keywords": "جان, سحرة, السيوطي",
      "pdf": "assets/pdf/books/laqat_marjan.pdf",
      "cover": "assets/book_covers/cover_1794579222808.jpg",
    },
    {
      "title": "وقاية الإنسان",
      "author": "المؤلف",
      "type": "كتب أخرى",
      "description": "كتاب في وقاية الإنسان من السحر والعين والحسد.",
      "keywords": "وقاية, عين, حسد, سحر",
      "pdf": "assets/pdf/books/waqaya_insan.pdf",
      "cover": "assets/book_covers/cover_1794579206567.jpg",
    },
  ];

  static const String aboutPlaceholder =
      "الراقي العراقي هو راقي شرعي متخصص في الرقية الشرعية وفق الكتاب والسنة، "
      "يقدم الرقاة والأذكار وكتب المؤلفات بشكل مجاني لمحب من خلال هذا التطبيق الإلكتروني الرسمي.";
}
