package com.mkgraiitr.investmentintelligence.ai;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.Test;

class AiFeaturePropertiesTest {

    @Test
    void defaultsKeepAiRuntimeDisabledAndOutputHarnessStrict() {
        var properties = new AiFeatureProperties(false, null, null);

        assertThat(properties.enabled()).isFalse();
        assertThat(properties.advisorChat().enabled()).isFalse();
        assertThat(properties.outputHarness().strictMode()).isTrue();
    }
}
