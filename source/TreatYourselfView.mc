import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.ActivityMonitor;
import Toybox.Lang;
import Toybox.Math;
import Toybox.System;


class TreatYourselfView extends WatchUi.View {

    private var _SALMON_COLOR as Number = Graphics.createColor(125, 255, 160, 122);
    private var _LIGHT_GRAY as Number = Graphics.createColor(215, 215, 215, 215);
    
    // Database of treats (name: calories)
    private var _treats as Dictionary = {
        "🍷 Glass of Wine" => 125,
        "🧁 Cupcake" => 150,
        "🍖 Saucisson" => 100,
        "🥄 Nutella Spoon" => 100,
        "🧀 Cheese Cube" => 80,
        "🍫 Chocolate" => 35,
        "🍟 Crisps" => 150,
        "🍦 Ice Cream Cone" => 200,
    };

    function initialize() {
        View.initialize();
    }

    // Load resources here
    function onLayout(dc as Dc) as Void { setLayout(Rez.Layouts.MainLayout(dc)); }
    
    // Finds the best treat based on available calories
    private function getTreat(giveTreat as Number) as Dictionary {
        if (giveTreat < 45) {
            return { :key => "No treat yet 🥺", :value => 0 };
        }
        
        var keys = _treats.keys();                 // -> Array of keys
        var randomIndex = Math.rand() % keys.size(); // -> Random index
        var key = keys[randomIndex];
        
        // Return the treat obj
        return { :key => key, :value => _treats[key] };
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        // Calculate calories using the new calculator
        var totalCaloriesBurned = CaloriesCalculator.getCurrentBurntCalories();
        var calorieGoal = CaloriesCalculator.getCalorieBurntGoal();
        var availableTreatCalories = CaloriesCalculator.getAvailableCaloriesForTreats();
        var treat = getTreat(availableTreatCalories);

        // --- Start of custom drawing ---
        drawGradientBackground(dc);
        drawCalorieProgressRing(dc, totalCaloriesBurned, calorieGoal);
        var treatCalories = drawTreatBadge(dc, treat, availableTreatCalories);
        drawGlassPanels(dc); // Draw panel on top of badge lower part
        drawStats(dc, treatCalories);
        // --- End of custom drawing ---
    }

    // Modern gradient background
    private function drawGradientBackground(dc as Dc) as Void {
        var w = dc.getWidth(); var h = dc.getHeight();
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        var cx = w/2; var cy = h/2;

        // Add some decorative arcs
        dc.setPenWidth(4);
        dc.setColor(_SALMON_COLOR, Graphics.COLOR_TRANSPARENT);
        dc.drawArc(cx, cy, cx, Graphics.ARC_COUNTER_CLOCKWISE, 300, 240);
    }

    // Glass style translucent panels
    private function drawGlassPanels(dc as Dc) as Void {
        var w = dc.getWidth(); var h = dc.getHeight();
        // A slightly transparent dark panel
        dc.setColor(_SALMON_COLOR, Graphics.COLOR_TRANSPARENT);
        dc.fillRoundedRectangle(0, h*0.675, w*1, h*0.58, 15);
        
        // A light border to give it a "glass" edge
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(1);
        dc.drawRoundedRectangle(0, h*0.675, w*1, h*0.58, 15);
    }

    // Circular progress ring for calories burned
    private function drawCalorieProgressRing(dc as Dc, burned as Number, goal as Number) as Void {
        var w = dc.getWidth(); var h = dc.getHeight();
        var cx = w/2; var cy = h*0.30; var radius = h*0.22;
        var pct = (burned * 1.0 / goal).toFloat();

        if (pct > 1) { pct = 1; }
        if (pct < 0) { pct = 0; }
        
        // Background circle
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(6);
        dc.drawCircle(cx, cy, radius);
        
        // Progress arc
        if (pct > 0) {
            var startAngle = 270; // Start at bottom
            var sweepAngle = (360 * pct).toNumber();
            dc.setColor(pct >= 0.8 ? Graphics.COLOR_GREEN : Graphics.COLOR_ORANGE, Graphics.COLOR_TRANSPARENT);
            dc.setPenWidth(8);
            dc.drawArc(cx, cy, radius, Graphics.ARC_CLOCKWISE, startAngle, startAngle - sweepAngle);
        }
  
        // Center text (calories burned)
        var centerText;
        if (burned >= 1000) { 
            centerText = (burned.toFloat() / 1000.0).format("%.1f") + "k"; 
        } else { 
            centerText = burned.toString(); 
        }
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, cy - dc.getFontHeight(Graphics.FONT_SMALL)/2 - 15, Graphics.FONT_SMALL, centerText, Graphics.TEXT_JUSTIFY_CENTER);
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, cy + dc.getFontHeight(Graphics.FONT_XTINY)/2 - 12, Graphics.FONT_XTINY, "cal burned", Graphics.TEXT_JUSTIFY_CENTER);
    }

    // Treat badge in the middle of the ring lower area
    private function drawTreatBadge(dc as Dc, treat as Dictionary, avail as Number) as Number {
        var w = dc.getWidth(); var h = dc.getHeight();
        var badgeW = w*0.70; var badgeH = h*0.12; var x = (w-badgeW)/2; var y = h*0.48;

        var bgColor = avail > 45 ? Graphics.COLOR_DK_GREEN : Graphics.COLOR_DK_RED;
        dc.setColor(bgColor, Graphics.COLOR_TRANSPARENT);
        dc.fillRoundedRectangle(x, y, badgeW, badgeH, 35);
        
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(1);
        dc.drawRoundedRectangle(x, y, badgeW, badgeH, 35);
        
        var treatName = treat.get(:key);
        var treatCalories = treat.get(:value) as Number;
        var treatText = treatName;

        var times = 1;
        if (treatCalories > 0) {
            times = (avail / treatCalories).toNumber();
            if (times > 0) {
                treatText = times.toString() + "x " + treatName;
            }
        }

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(w/2, y + badgeH/2, Graphics.FONT_XTINY, treatText, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    
        return times * treatCalories;
    }

    private function drawStats(dc as Dc, treatsCalories as Number) as Void {
        var w = dc.getWidth(); var h = dc.getHeight();
        var panelY = h * 0.63;
        var panelH = h * 0.28;
        var xCenter = w / 2;
        var yStart = panelY;
        var lineH = (panelH - 20) / 3;
        
        // Line 1: BMR
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(xCenter, yStart + lineH, Graphics.FONT_XTINY, "BMR: " + CaloriesCalculator.getBMR() + " cal", Graphics.TEXT_JUSTIFY_CENTER);

        // Line 2: Estimated calorie burn
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(xCenter, yStart + lineH * 2, Graphics.FONT_XTINY, "EoD: " + CaloriesCalculator.getEstimatedDailyCalories().toString() + " cal", Graphics.TEXT_JUSTIFY_CENTER);

        // Line 3: 
        if (treatsCalories > 0) {
            dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
            dc.drawText(xCenter, yStart + lineH * 3, Graphics.FONT_XTINY, "Treats: " + treatsCalories.toString() + " cal", Graphics.TEXT_JUSTIFY_CENTER);
        } else {
            dc.setColor(_LIGHT_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawText(xCenter, yStart + lineH * 3, Graphics.FONT_XTINY, "Almost there!", Graphics.TEXT_JUSTIFY_CENTER);
        }
    }

    function onHide() as Void {}
}
