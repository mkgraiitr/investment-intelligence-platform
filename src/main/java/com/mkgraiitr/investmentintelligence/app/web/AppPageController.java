package com.mkgraiitr.investmentintelligence.app.web;

import java.util.Map;
import java.util.Set;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;

@Controller
public class AppPageController {

    private static final Set<String> PLACEHOLDER_PAGES = Set.of(
            "discover",
            "watchlist",
            "research",
            "insights",
            "intelligence",
            "policy-settings"
    );

    private static final Map<String, String> PAGE_TITLES = Map.of(
            "discover", "Discover",
            "watchlist", "Watchlist & Themes",
            "research", "Research / Analysis Workspace",
            "insights", "Insights",
            "intelligence", "Intelligence",
            "policy-settings", "Policy & Settings"
    );

    private static final Map<String, String> PAGE_DESCRIPTIONS = Map.of(
            "discover", "Market Scanner, Hot Themes, Sentiment Movers, and Speculative Radar will live here.",
            "watchlist", "Track ideas from articles, friends, newsletters, social buzz, or personal research.",
            "research", "Deep-dive workspace for assets, sectors, and themes.",
            "insights", "Safe attention labels with policy, scoring, and evidence context.",
            "intelligence", "News, sentiment, announcements, deals, projects, and narratives.",
            "policy-settings", "Policy, benchmarks, providers, profile, preferences, and future-ready settings."
    );

    @GetMapping("/")
    public String index() {
        return "redirect:/app/home";
    }

    @GetMapping("/app/home")
    public String home(Model model) {
        model.addAttribute("activePath", "/app/home");
        model.addAttribute("pageTitle", "Home / Daily Brief");
        model.addAttribute("pageDescription", "A configurable landing page for portfolio status, market signals, alerts, and attention items.");
        return "home";
    }

    @GetMapping("/app/{page}")
    public String placeholderPage(@PathVariable String page, Model model) {
        if (!PLACEHOLDER_PAGES.contains(page)) {
            return "redirect:/app/home";
        }

        model.addAttribute("activePath", "/app/" + page);
        model.addAttribute("pageTitle", PAGE_TITLES.get(page));
        model.addAttribute("pageDescription", PAGE_DESCRIPTIONS.get(page));
        return "placeholder";
    }
}
