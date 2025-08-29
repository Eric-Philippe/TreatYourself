import Toybox.Lang;
import Toybox.ActivityMonitor;
import Toybox.UserProfile.*;
import Toybox.Time;
using Toybox.System;
using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.Application;

class UserMetadata {   
    public static function getTargetBeforeTreat() as Number {
        return Application.Properties.getValue("targetBeforeTreat");
    }

    public static function getTargetDeficit() as Number {
        return Application.Properties.getValue("targetDeficit");
    }

    public static function getHeight() as Number {
        var userHeight = UserProfile.getProfile().height;
        if (userHeight == null || userHeight <= 0) {
            userHeight = 170; // Default value
        }

        return userHeight;
    }

    public static function getWeight() as Number {
        var userWeight = UserProfile.getProfile().weight;
        if (userWeight == null || userWeight <= 0) {
            userWeight = 70; // Default value
        } else {
            userWeight = userWeight / 1000; // Convert grams to kilograms
        }

        return userWeight;
    }

    public static function getAge() as Number {
        var userBirthYear = UserProfile.getProfile().birthYear;
        if (userBirthYear == null || userBirthYear <= 0) {
            userBirthYear = 1990; // Default value
        }
        var today = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
        var currentYear = today.year;
        return currentYear - userBirthYear;
    }

    public static function getSex() as String {
        var userSex = UserProfile.getProfile().gender;
        if (userSex == null || userSex == "") {
            userSex = "female"; // Default value
        }

        if (userSex.equals(UserProfile.GENDER_FEMALE)) {
            return "female";
        } else {
            return "male";
        }
    }

    // Get current steps from the watch
    public static function getCurrentSteps() as Number {
        var info = ActivityMonitor.getInfo();
        return info.steps != null ? info.steps : 0;
    }
    
    // Get current active minutes from the watch
    public static function getCurrentActiveMinutes() as Number {
        var info = ActivityMonitor.getInfo();
        return info.activeMinutesDay != null ? info.activeMinutesDay.total : 0;
    }
    
    // Get complete activity info from the watch
    public static function getActivityInfo() as Dictionary {
        var info = ActivityMonitor.getInfo();
        var steps = info.steps != null ? info.steps : 0;
        var activeMinutes = info.activeMinutesDay != null ? info.activeMinutesDay.total : 0;

        return {
            "steps" => steps,
            "activeMinutes" => activeMinutes
        };
    }

    public static function intoString() as String {
        return "UserMetadata{age=" + getAge().toString() + ", height=" + getHeight().toString() + ", weight=" + getWeight().toString() + ", sex=" + getSex().toString() + "}";
    }
}
