import Toybox.Lang;
import Toybox.Time;
import Toybox.Math;

class CaloriesCalculator {
    
    // Activity factors for different intensity levels
    private static var ACTIVITY_FACTORS as Dictionary = {
        "sedentary" => 1.2,     // Not or little exercise
        "light" => 1.375,       // Light exercise 1-3 days/week
        "moderate" => 1.55,     // Moderate exercise 3-5 days/week
        "active" => 1.725,      // Intense exercise 6-7 days/week
        "very_active" => 1.9    // Very intense exercise, physical job
    };

    // MET values for different activities
    private static var WALKING_MET as Float = 2.3; // Average walking MET
    private static var ACTIVE_MINUTES_MET as Float = 4.2; // Average MET for active minutes
    
    // Calculate BMR using Mifflin-St Jeor equation
    private static function calculateBMR() as Float {
        var bmr;
        
        if (UserMetadata.getSex().equals("female")) {
            bmr = (10 * UserMetadata.getWeight()) + (6.25 * UserMetadata.getHeight()) - (5 * UserMetadata.getAge()) - 161;
        } else {
            bmr = (10 * UserMetadata.getWeight()) + (6.25 * UserMetadata.getHeight()) - (5 * UserMetadata.getAge()) + 5;
        }
        
        return bmr;
    }
    
    // Calculate calories burned from steps
    private static function getCaloriesFromSteps(steps as Number) as Float {
        var weightKg = UserMetadata.getWeight();
        // Estimate walking time: average 4000 steps per hour
        var walkingHours = steps / 4000.0;
        // MET formula: METs × weight (kg) × time (hours)
        return WALKING_MET * weightKg * walkingHours;
    }
    
    // Calculate calories from active minutes
    private static function getCaloriesFromActiveMinutes(activeMinutes as Number) as Float {
        var weightKg = UserMetadata.getWeight();
        var activeHours = activeMinutes / 60.0;
        // Using higher MET value for active minutes
        return ACTIVE_MINUTES_MET * weightKg * activeHours;
    }
    
    // Get elapsed time since midnight in hours
    private static function getElapsedHoursToday() as Float {
        var now = Time.now();
        var today = Time.today();
        var elapsedSeconds = now.value() - today.value();
        return elapsedSeconds / 3600.0; // Convert to hours
    }
    
    // Calculate basal calories burned since midnight
    private static function getBasalCaloriesToday() as Float {
        var bmr = calculateBMR();
        var elapsedHours = getElapsedHoursToday();
        // BMR is daily rate, so divide by 24 to get hourly rate
        return (bmr / 24.0) * elapsedHours;
    }
    
    // Get current total calories burned today
    public static function getCurrentBurntCalories() as Number {
        var activityInfo = UserMetadata.getActivityInfo();
        var steps = activityInfo["steps"] as Number;
        var activeMinutes = activityInfo["activeMinutes"] as Number;
        
        var basalCals = getBasalCaloriesToday();
        var stepsCals = getCaloriesFromSteps(steps);
        var activeCals = getCaloriesFromActiveMinutes(activeMinutes) - stepsCals; // Avoid double counting steps
        
        var totalCals = basalCals + stepsCals + activeCals;
        return totalCals.toNumber();
    }
    
    // Estimate total calories that will be burned by end of day
    public static function getEstimatedDailyCalories() as Number {
        var currentCals = getCurrentBurntCalories();
        var elapsedHours = getElapsedHoursToday();
        
        // If it's early in the day, use a more conservative projection
        if (elapsedHours < 1.0) {
            // Use BMR * light activity factor as baseline
            var bmr = calculateBMR();
            return (bmr * ACTIVITY_FACTORS["light"]).toNumber();
        }
        
        // Calculate current hourly burn rate
        var hourlyRate = currentCals / elapsedHours;
        var remainingHours = 24.0 - elapsedHours;
        
        // For remaining hours, assume 70% of current activity rate (people are less active in evening)
        var projectedRemainingCals = remainingHours * hourlyRate * 0.7;
        
        var estimatedTotal = currentCals + projectedRemainingCals;
        return estimatedTotal.toNumber();
    }
    
    // Get calories remaining for treats (based on target deficit)
    public static function getAvailableCaloriesForTreats() as Number {
        // Estimated total calories - (BMR - target deficit)
        var estimatedTotal = getEstimatedDailyCalories();

        var available = estimatedTotal - getCalorieBurntGoal() - UserMetadata.getTargetDeficit();
        return available > 0 ? available.toNumber() : 0;

    }

    public static function getCalorieBurntGoal() as Number {
        if (UserMetadata.getTargetBeforeTreat() != null) {
            return UserMetadata.getTargetBeforeTreat().toNumber();
        }

        var bmr = calculateBMR();
        return (bmr + 300).toNumber();
    }

    // Return BMR as string rounded with no decimal places
    public static function getBMR() as String {
        return calculateBMR().toNumber().toString();
    }
}