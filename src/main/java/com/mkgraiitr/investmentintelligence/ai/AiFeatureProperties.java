package com.mkgraiitr.investmentintelligence.ai;

import org.springframework.boot.context.properties.ConfigurationProperties;

@ConfigurationProperties(prefix = "ai")
public record AiFeatureProperties(
        boolean enabled,
        AdvisorChat advisorChat,
        OutputHarness outputHarness
) {

    public AiFeatureProperties {
        advisorChat = advisorChat == null ? new AdvisorChat(false) : advisorChat;
        outputHarness = outputHarness == null ? new OutputHarness(true) : outputHarness;
    }

    public record AdvisorChat(boolean enabled) {
    }

    public record OutputHarness(boolean strictMode) {
    }
}
