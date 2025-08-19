class OnboardModel {
  String image, name;

  OnboardModel({required this.image, required this.name});
}

List<OnboardModel> onboarding = [
   OnboardModel(
    image: 'lib/assets/images/onboarding/1.jpg',
    name: "Zaman Burada Akıyor.",
  ),
  OnboardModel(
    image: 'lib/assets/images/onboarding/2.jpg',
    name: "İzmir'in Antik Harikaları",
  ),
  OnboardModel(
    image: 'lib/assets/images/onboarding/3.jpg',
    name: 'Ege’nin Saklı Cenneti',
  ),
  OnboardModel(
    image: 'lib/assets/images/onboarding/4.jpg',
    name: 'Geçmişe Açılan Kapı',
  ),
];