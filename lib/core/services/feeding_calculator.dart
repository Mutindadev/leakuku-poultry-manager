class FeedingCalculator {
  /// Returns daily food requirement in grams based on breed and age in days
  static double getDailyFoodGrams(String breed, int ageDays) {
    final breedLower = breed.toLowerCase();
    
    if (breedLower.contains('broiler')) {
      return _getBroilerDailyFood(ageDays);
    } else if (breedLower.contains('kienye')) {
      return _getKienyejiDailyFood(ageDays);
    } else if (breedLower.contains('layer')) {
      return _getLayerDailyFood(ageDays);
    }
    
    return 50.0; // Default fallback
  }

  /// Broilers: Week 1=20g, Week 2=40g, Week 3=80g, Week 4=120g, then +40g/week
  static double _getBroilerDailyFood(int ageDays) {
    final week = (ageDays / 7).ceil();
    
    if (week <= 0) return 20.0;
    if (week == 1) return 20.0;
    if (week == 2) return 40.0;
    if (week == 3) return 80.0;
    if (week == 4) return 120.0;
    
    // After week 4: +40g per week
    return 120.0 + ((week - 4) * 40.0);
  }

  /// Improved Kienyeji: Start 20g, add 5g per week
  static double _getKienyejiDailyFood(int ageDays) {
    final week = (ageDays / 7).ceil();
    if (week <= 0) return 20.0;
    return 20.0 + ((week - 1) * 5.0);
  }

  /// Layers: Same as Kienyeji - Start 20g, add 5g per week
  static double _getLayerDailyFood(int ageDays) {
    final week = (ageDays / 7).ceil();
    if (week <= 0) return 20.0;
    return 20.0 + ((week - 1) * 5.0);
  }

  /// Returns weekly food requirement in grams
  static double getWeeklyFoodGrams(String breed, int ageDays) {
    return getDailyFoodGrams(breed, ageDays) * 7;
  }

  /// Returns maturity target in days based on breed
  static int getMaturityDays(String breed) {
    final breedLower = breed.toLowerCase();
    
    if (breedLower.contains('broiler')) {
      return 35; // 35 days
    } else if (breedLower.contains('kienye')) {
      return 90; // 81-100 days average
    } else if (breedLower.contains('layer')) {
      return 150; // 5-6 months = ~150 days
    }
    
    return 90; // Default
  }

  /// Returns days remaining until maturity
  static int getDaysToMaturity(String breed, int currentAgeDays) {
    final maturityDays = getMaturityDays(breed);
    final remaining = maturityDays - currentAgeDays;
    return remaining > 0 ? remaining : 0;
  }

  /// Returns progress percentage (0-100)
  static double getMaturityProgress(String breed, int currentAgeDays) {
    final maturityDays = getMaturityDays(breed);
    if (maturityDays == 0) return 0.0;
    
    final progress = (currentAgeDays / maturityDays) * 100;
    return progress > 100 ? 100.0 : progress;
  }
}
