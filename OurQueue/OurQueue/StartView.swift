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
            
            UIView.animate(withDuration: duration, delay: delay, options: [.curveEaseInOut], animations: {
                f.alpha = 1.0;
                f.frame.origin = origin;
            });
            delay += 0.5;
        }
        
        
        
    }
    
    
    func colorGradientAnimation(_ item: UIButton){
        let duration = 20.0
        let numColors = 5.0;
        let step:Double = numColors/duration;
        UIView.animateKeyframes(withDuration: duration, delay: 1.5, options: [.repeat, .allowUserInteraction], animations: {
            UIView.addKeyframe(withRelativeStartTime: (0.0/numColors), relativeDuration: step, animations: {
                item.backgroundColor = #colorLiteral(red: 0.8823529412, green: 0.3529411765, blue: 0.5921568627, alpha: 1);
            });
            UIView.addKeyframe(withRelativeStartTime: (1.0/numColors), relativeDuration: step, animations: {
                item.backgroundColor = #colorLiteral(red: 0.5254901961, green: 0.07450980392, blue: 0.5333333333, alpha: 1);
            });
            UIView.addKeyframe(withRelativeStartTime: (2.0/numColors), relativeDuration: step, animations: {
                item.backgroundColor = #colorLiteral(red: 0.6, green: 0.5176470588, blue: 0.831372549, alpha: 1);
            });
            UIView.addKeyframe(withRelativeStartTime: (3.0/numColors), relativeDuration: step, animations: {
                item.backgroundColor = #colorLiteral(red: 0.937254902, green: 0.4745098039, blue: 0.5411764706, alpha: 1);
            });
            UIView.addKeyframe(withRelativeStartTime: (4.0/numColors), relativeDuration: step, animations: {
                item.backgroundColor = #colorLiteral(red: 0.1098039216, green: 0.7254901961, blue: 0.3294117647, alpha: 1);
            });
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

