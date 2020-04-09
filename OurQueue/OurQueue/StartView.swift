//
//  StartView.swift
//  OurQueue
//
//  Created by Brendan DeMilt on 4/5/20.
//  Copyright © 2020 Brendan DeMilt. All rights reserved.
//



class StartView: UIView{
    
    
    var slides: [UIView] = [];
    var fades: [UIView] = [];
    
    
    
    
    func fadeIn(){
        let duration = 1.0;
        for f in fades {
            f.alpha = 0.0;
           UIView.animate(withDuration: duration, animations: {
               f.alpha = 1.0;
           });
        }
    }
    
    func slideIn(){
        let duration = 1.5;
        var delay = 0.0;
        for f in slides {
            let origin = f.frame.origin;
            f.alpha = 0.0;
            f.frame.origin = CGPoint(x: origin.x, y: origin.y+500);
            
            UIView.animate(withDuration: duration, delay: delay, options: [.curveEaseInOut, .allowUserInteraction], animations: {
                f.alpha = 1.0;
                f.frame.origin = origin;
            });
            delay += 0.5;
        }
        
        
        
    }
    
    
    func colorGradientAnimation(_ item: UIButton){
        let numColors = 5.0;
        let duration = 20.0;
        let colors = [#colorLiteral(red: 0.9725490196, green: 0.4, blue: 0.1411764706, alpha: 1),#colorLiteral(red: 0.9176470588, green: 0.2078431373, blue: 0.2745098039, alpha: 1),#colorLiteral(red: 0.9764705882, green: 0.7843137255, blue: 0.05490196078, alpha: 1),#colorLiteral(red: 0.3294117647, green: 0.7764705882, blue: 0.9215686275, alpha: 1),#colorLiteral(red: 0.1137254902, green: 0.7254901961, blue: 0.3294117647, alpha: 1)]
        
        let step:Double = numColors/duration;
        UIView.animateKeyframes(withDuration: duration, delay: 1.5, options: [.repeat, .allowUserInteraction, .beginFromCurrentState], animations: {
            for (index, color) in colors.enumerated() {
            UIView.addKeyframe(withRelativeStartTime: Double(index)/numColors, relativeDuration: step, animations: {
                item.backgroundColor = color;
            });
            }
        });
        
        
        
    }
    
    
    
    func addSlideInStep(_ item: UIView) {
        slides.append(item);
        
    }
    
    
    func addFadeInStep(_ item: UIView) {
        fades.append(item);
    }
    
    
    
    
    func addAllSlideSubviews(){
        for v in self.subviews {
            slides.append(v);
        }
    }
    
    
    

    
    
    
    
    
    
}

