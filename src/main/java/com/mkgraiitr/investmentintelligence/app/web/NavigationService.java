package com.mkgraiitr.investmentintelligence.app.web;

import java.util.List;

import org.springframework.stereotype.Service;

@Service
public class NavigationService {

    private final List<NavigationItem> mainNavigation = List.of(
            new NavigationItem("Home / Daily Brief", "/app/home", "Today’s portfolio status, market signals, alerts, and attention items."),
            new NavigationItem("Portfolio", "/app/portfolio", "Holdings, allocation, cash, concentration, benchmark comparison, and policy-aware risk."),
            new NavigationItem("Discover", "/app/discover", "Market ideas, themes, sentiment movers, announcements, and tracking candidates."),
            new NavigationItem("Watchlist & Themes", "/app/watchlist", "Stocks, ETFs, sectors, themes, technologies, and external ideas being tracked."),
            new NavigationItem("Research / Analysis Workspace", "/app/research", "Deep-dive analysis for a stock, ETF, sector, or theme."),
            new NavigationItem("Insights", "/app/insights", "Safe non-execution attention labels and supporting evidence."),
            new NavigationItem("Intelligence", "/app/intelligence", "News, sentiment, announcements, deals, projects, and narratives."),
            new NavigationItem("Policy & Settings", "/app/policy-settings", "Policy, benchmarks, providers, profile, preferences, and future-ready settings.")
    );

    public List<NavigationItem> mainNavigation() {
        return mainNavigation;
    }
}
