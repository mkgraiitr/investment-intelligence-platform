package com.mkgraiitr.investmentintelligence.portfolio;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class PortfolioPageController {

    private final PortfolioViewService portfolioViewService;

    public PortfolioPageController(PortfolioViewService portfolioViewService) {
        this.portfolioViewService = portfolioViewService;
    }

    @GetMapping("/app/portfolio")
    public String portfolio(Model model) {
        model.addAttribute("activePath", "/app/portfolio");
        model.addAttribute("pageTitle", "Portfolio");
        model.addAttribute("pageDescription", "Holdings, allocation, cash, concentration, benchmark comparison, and policy-aware risk.");
        model.addAttribute("view", portfolioViewService.personalModePortfolio());
        return "portfolio";
    }

    @GetMapping("/hx/portfolio/context")
    public String portfolioContext(Model model) {
        model.addAttribute("view", portfolioViewService.personalModePortfolio());
        return "fragments/portfolio :: context";
    }

    @GetMapping("/hx/portfolio/summary")
    public String portfolioSummary(Model model) {
        model.addAttribute("view", portfolioViewService.personalModePortfolio());
        return "fragments/portfolio :: summary";
    }

    @GetMapping("/hx/portfolio/report-visualizations")
    public String portfolioCharts(Model model) {
        model.addAttribute("view", portfolioViewService.personalModePortfolio());
        return "fragments/portfolio :: charts";
    }

    @GetMapping("/hx/portfolio/holdings")
    public String portfolioHoldings(Model model) {
        model.addAttribute("view", portfolioViewService.personalModePortfolio());
        return "fragments/portfolio :: holdings";
    }
}
