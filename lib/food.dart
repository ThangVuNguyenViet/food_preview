class Food {
  final String name;
  final String description;
  final String image;
  final List<Ingredient> ingredients;

  const Food({
    required this.name,
    required this.description,
    required this.image,
    required this.ingredients,
  });

  static const pho = Food(
    name: 'Pho',
    description:
        'Pho is a Vietnamese soup consisting of broth, rice noodles, herbs, and meat.',
    image: 'assets/pho.png',
    ingredients: [
      Ingredient(name: 'Beef', image: 'assets/beef.jpg'),
      Ingredient(name: 'Rice noodles', image: 'assets/noodle.jpeg'),
      Ingredient(name: 'Herbs', image: 'assets/herb.jpg'),
      Ingredient(name: 'Eggs', image: 'assets/egg.jpg'),
      Ingredient(name: 'Bean Sprouts', image: 'assets/bean-sprouts.jpg'),
      Ingredient(name: 'Sauce', image: 'assets/sauce.png'),
    ],
  );
}

class Ingredient {
  final String name;
  final String image;

  const Ingredient({
    required this.name,
    required this.image,
  });
}
