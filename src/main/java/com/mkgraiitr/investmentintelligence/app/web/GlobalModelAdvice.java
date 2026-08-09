package com.mkgraiitr.investmentintelligence.app.web;

import com.mkgraiitr.investmentintelligence.ai.AiFeatureProperties;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ModelAttribute;

@ControllerAdvice
public class GlobalModelAdvice {

    private final NavigationService navigationService;
    private final AiFeatureProperties aiFeatureProperties;

    public GlobalModelAdvice(NavigationService navigationService, AiFeatureProperties aiFeatureProperties) {
        this.navigationService = navigationService;
        this.aiFeatureProperties = aiFeatureProperties;
    }

    @ModelAttribute("navigation")
    public Iterable<NavigationItem> navigation() {
        return navigationService.mainNavigation();
    }

    @ModelAttribute("aiEnabled")
    public boolean aiEnabled() {
        return aiFeatureProperties.enabled();
    }

    @ModelAttribute("advisorChatEnabled")
    public boolean advisorChatEnabled() {
        return aiFeatureProperties.enabled() && aiFeatureProperties.advisorChat().enabled();
    }
}
