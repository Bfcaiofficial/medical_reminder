class City {
  final String id;
  final String name;
  final double latitude;
  final double longitude;

  City({
    this.id,
    this.name,
    this.latitude,
    this.longitude,
  });
}

List<City> getEgyptCities(langCode) => [
      City(
        id: 'cairo',
        name: langCode == 'en' ? 'Cairo' : 'القاهرة',
        latitude: 30.07708,
        longitude: 31.285909,
      ),
      City(
        id: 'alex',
        name: langCode == 'en' ? 'Alexandria' : 'الاسكندرية',
        latitude: 31.215645,
        longitude: 29.955266,
      ),
      City(
        id: 'giza',
        name: langCode == 'en' ? 'Al Jizah' : 'الجيزة',
        latitude: 30.008079,
        longitude: 31.210931,
      ),
      City(
        id: 'ismailia',
        name: langCode == 'en' ? 'Ismailia' : 'الاسماعيلية',
        latitude: 30.604272,
        longitude: 32.272252,
      ),
      City(
        id: 'portsaid',
        name: langCode == 'en' ? 'Port Said' : 'بور سعيد',
        latitude: 31.256541,
        longitude: 32.284115,
      ),
      City(
        id: 'luxor',
        name: langCode == 'en' ? 'Luxor' : 'الاقصر',
        latitude: 25.695858,
        longitude: 32.643592,
      ),
      City(
        id: 'sohag',
        name: langCode == 'en' ? 'Suhaj' : 'سوهاج',
        latitude: 26.556952,
        longitude: 31.694785,
      ),
      City(
        id: 'mansora',
        name: langCode == 'en' ? 'Al Manşurah' : 'المنصورة',
        latitude: 31.036373,
        longitude: 31.380691,
      ),
      City(
        id: 'suiz',
        name: langCode == 'en' ? 'Suez' : 'السويس',
        latitude: 29.973714,
        longitude: 32.526267,
      ),
      City(
        id: 'minia',
        name: langCode == 'en' ? 'Al Minya' : 'المنيا',
        latitude: 28.109884,
        longitude: 30.750299,
      ),
      City(
        id: 'ib-damanhur',
        name: langCode == 'en' ? 'Ib‘adiyat Damanhur' : 'ابعادية دمنهور',
        latitude: 31.032821,
        longitude: 30.42527,
      ),
      City(
        id: 'bani-suwayf',
        name: langCode == 'en' ? 'Bani Suwayf' : 'بنى سويف',
        latitude: 29.074409,
        longitude: 31.097848,
      ),
      City(
        id: 'asyut',
        name: langCode == 'en' ? 'Asyut' : 'اسيوط',
        latitude: 27.180956,
        longitude: 31.183683,
      ),
      City(
        id: 'tanta',
        name: langCode == 'en' ? 'Tanta' : 'طنطا',
        latitude: 30.788471,
        longitude: 31.001921,
      ),
      City(
        id: 'fayyum',
        name: langCode == 'en' ? 'Al Fayyum' : 'الفيوم',
        latitude: 29.309949,
        longitude: 30.841804,
      ),
      City(
        id: 'aswan',
        name: langCode == 'en' ? 'Aswan' : 'اسوان',
        latitude: 24.093433,
        longitude: 32.907038,
      ),
      City(
        id: 'qina',
        name: langCode == 'en' ? 'Qina' : 'قنا',
        latitude: 26.164179,
        longitude: 32.72671,
      ),
      City(
        id: 'arish',
        name: langCode == 'en' ? 'Al ‘Arish' : 'العريش',
        latitude: 31.12866,
        longitude: 33.797117,
      ),
      City(
        id: 'qalyubiyah',
        name: langCode == 'en' ? 'Al Qalyubiyah' : 'القليوبية',
        latitude: 30.459065,
        longitude: 31.178577,
      ),
      City(
        id: 'mas-samalut',
        name: langCode == 'en' ? 'Ma‘şarat Samalut' : 'معصرة سمالوط',
        latitude: 28.316667,
        longitude: 30.716667,
      ),
      City(
        id: 'kafr-shaykh',
        name: langCode == 'en' ? 'Kafr ash Shaykh' : 'كفر الشيخ',
        latitude: 31.114304,
        longitude: 30.940116,
      ),
      City(
        id: 'jirja',
        name: langCode == 'en' ? 'Jirja' : 'جرجا',
        latitude: 26.338255,
        longitude: 31.89161,
      ),
      City(
        id: 'matruh',
        name: langCode == 'en' ? 'Marsá Matruh' : 'معصرة مطروح',
        latitude: 31.352539,
        longitude: 27.245275,
      ),
      City(
        id: 'isna',
        name: langCode == 'en' ? 'Isna' : 'اسنا',
        latitude: 25.293356,
        longitude: 32.554018,
      ),
      City(
        id: 'bani-mazar',
        name: langCode == 'en' ? 'Bani Mazar' : 'بنى مزار',
        latitude: 28.503599,
        longitude: 30.800401,
      ),
      City(
        id: 'kharijah',
        name: langCode == 'en' ? 'Al Kharijah' : 'الخارجة',
        latitude: 25.451405,
        longitude: 30.546346,
      ),
      City(
        id: 'safajah',
        name: langCode == 'en' ? 'Bur Safajah' : 'بور سفاجة',
        latitude: 26.729177,
        longitude: 33.936511,
      ),
      City(
        id: 'altur',
        name: langCode == 'en' ? 'At tur' : 'الطور',
        latitude: 28.236381,
        longitude: 33.625404,
      ),
      City(
        id: 'siwah',
        name: langCode == 'en' ? 'Siwah' : 'سيوة',
        latitude: 29.20133,
        longitude: 25.521545,
      ),
      City(
        id: 'dabah',
        name: langCode == 'en' ? 'Ad Dab‘ah' : 'الضبعة',
        latitude: 31.028189,
        longitude: 28.444976,
      ),
      City(
        id: 'alamayn',
        name: langCode == 'en' ? 'Al ‘Alamayn' : 'العالمين',
        latitude: 30.830066,
        longitude: 28.955019,
      ),
      City(
        id: 'sallum',
        name: langCode == 'en' ? 'As Sallum' : 'السلوم',
        latitude: 31.553713,
        longitude: 25.157927,
      ),
      City(
        id: 'farafirah',
        name: langCode == 'en' ? 'Qaşr al Farafirah' : 'قصر الفرافرة',
        latitude: 27.056799,
        longitude: 27.969793,
      ),
      City(
        id: 'ghardaqah',
        name: langCode == 'en' ? 'Al Ghardaqah' : 'الغردقة',
        latitude: 27.252891,
        longitude: 33.818108,
      ),
      City(
        id: 'bir-abd',
        name: langCode == 'en' ? 'Bi’r al ‘Abd' : 'بير العبد',
        latitude: 31.018874,
        longitude: 33.0098,
      ),
      City(
        id: 'rafah',
        name: langCode == 'en' ? 'Rafah' : 'رفح',
        latitude: 31.287806,
        longitude: 34.238071,
      ),
      City(
        id: 'damanhur',
        name: langCode == 'en' ? 'Damanhur' : 'دمنهور',
        latitude: 31.034084,
        longitude: 30.468233,
      ),
      City(
        id: 'shibin-kawm',
        name: langCode == 'en' ? 'Shibin al Kawm' : 'شبين الكوم',
        latitude: 30.552581,
        longitude: 31.009035,
      ),
      City(
        id: 'damietta',
        name: langCode == 'en' ? 'Damietta' : 'دمياط',
        latitude: 31.416477,
        longitude: 31.813316,
      ),
      City(
        id: 'shaykh-zuwayd',
        name: langCode == 'en' ? 'Ash Shaykh Zuwayd' : 'الشيخ زويد',
        latitude: 31.216297,
        longitude: 34.110742,
      ),
      City(
        id: 'zaqaziq',
        name: langCode == 'en' ? 'Az Zaqaziq' : 'الزقازيق',
        latitude: 30.587676,
        longitude: 31.501997,
      ),
    ];
