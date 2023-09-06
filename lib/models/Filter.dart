class Filter {
  late List<int> categories;
  late List<int> shops;
  String name = "";
  double  min_price =1;
  double  max_price=9999;

  Filter() {
    categories = [];
    shops = [];

  }

  Filter.clear() {
    categories = [];
      min_price =1;
     max_price=9999;
  }

  clearCategory(){
    this.categories = [];
  }

  toggleCategory(int categoryId) {
    if (categories.contains(categoryId)) {
      categories.remove(categoryId);
    } else {
      categories.add(categoryId);
    }
  }

  toggleShop(int shopId) {
    if (shops.contains(shopId)) {
      shops.remove(shopId);
    } else {
      shops.add(shopId);
    }
  }


}
