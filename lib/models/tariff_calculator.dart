import 'package:flutter/material.dart';

class TariffCalculator {
  static const double basePrice = 28.0;
  static const double distancePricePerKm = 1.0;
  static const double passengerPriceForThree = 5.0;
  static const double passengerPriceForFour = 16.0;
  static const double discountForStudentOrSenior = 3.0;
  static const double additionalPriceOutsideArea = 5.0;
  static const double areaRadius = 10.0; // Radius of the specific area in kilometers

  static double calculateTariff(int distance, int passengerCount, bool isStudentOrSenior, bool isWithinArea) {
    double totalDistancePrice = (distance > 2) ? ((distance - 2) * distancePricePerKm) + basePrice : basePrice;
    double passengerPrice = 0.0;

    if (passengerCount == 3) {
      passengerPrice = passengerPriceForThree;
    } else if (passengerCount == 4) {
      passengerPrice = passengerPriceForFour;
    }

    double discountPrice = isStudentOrSenior ? discountForStudentOrSenior : 0.0;

    double additionalPrice = isWithinArea ? 0.0 : additionalPriceOutsideArea;

    double totalTariff = totalDistancePrice + passengerPrice - discountPrice + additionalPrice;

    return totalTariff;
  }
}


