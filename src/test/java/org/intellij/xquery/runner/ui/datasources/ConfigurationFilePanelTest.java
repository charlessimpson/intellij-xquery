package org.intellij.xquery.runner.ui.datasources;

import org.fest.swing.edt.GuiActionRunner;
import org.fest.swing.edt.GuiQuery;
import org.fest.swing.fixture.FrameFixture;
import org.intellij.xquery.runner.rt.XQueryDataSourceType;
import org.intellij.xquery.runner.ui.PanelTestingFrame;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;

import static org.hamcrest.Matchers.is;
import static org.junit.Assert.assertThat;

/**
 * User: ligasgr
 * Date: 24/10/13
 * Time: 13:42
 */
public class ConfigurationFilePanelTest {
    private FrameFixture window;
    private ConfigurationFilePanel configurationFilePanel;

    @Before
    public void setUp() throws Exception {
        PanelTestingFrame frame = GuiActionRunner.execute(new GuiQuery<PanelTestingFrame>() {
            protected PanelTestingFrame executeInEDT() {
                configurationFilePanel = new ConfigurationFilePanel();
                return new PanelTestingFrame(configurationFilePanel.getMainPanel());
            }
        });
        window = new FrameFixture(frame);
        window.show();
    }

    @Test
    public void shouldShowPanelWhenNeeded() throws Exception {
        configurationFilePanel.init(XQueryDataSourceType.SAXON, false, null);

        assertThat(configurationFilePanel.getMainPanel().isVisible(), is(true));
    }

    @Test
    public void shouldHidePanelWhenNeeded() throws Exception {
        configurationFilePanel.init(XQueryDataSourceType.MARKLOGIC, false, null);

        assertThat(configurationFilePanel.getMainPanel().isVisible(), is(false));
    }

    @Test
    public void shouldDisableConfigFileField() throws Exception {
        configurationFilePanel.init(XQueryDataSourceType.SAXON, false, null);

        window.checkBox("configurationEnabled").requireNotSelected();
        window.textBox("configFile").requireDisabled();

    }

    @Test
    public void shouldEnableConfigFileField() throws Exception {
        configurationFilePanel.init(XQueryDataSourceType.SAXON, true, null);

        window.checkBox("configurationEnabled").requireSelected();
        window.textBox("configFile").requireEnabled();
    }

    @Test
    public void shouldChangeValueOfConfigurationEnabledToTrue() throws Exception {
        configurationFilePanel.init(XQueryDataSourceType.SAXON, false, null);

        window.checkBox("configurationEnabled").check();
        window.checkBox("configurationEnabled").requireSelected();
        window.textBox("configFile").requireEnabled();
        assertThat(configurationFilePanel.isConfigurationEnabled(), is(true));
    }

    @Test
    public void shouldChangeValueOfConfigurationEnabledToFalse() throws Exception {
        configurationFilePanel.init(XQueryDataSourceType.SAXON, true, null);

        window.checkBox("configurationEnabled").uncheck();
        window.checkBox("configurationEnabled").requireNotSelected();
        window.textBox("configFile").requireDisabled();
        assertThat(configurationFilePanel.isConfigurationEnabled(), is(false));
    }

    @Test
    public void shouldChangeValueOfConfigFileWhenTextEntered() throws Exception {
        configurationFilePanel.init(XQueryDataSourceType.SAXON, true, null);

        window.textBox("configFile").enterText("/my/file");
        assertThat(configurationFilePanel.getConfigFile(), is("/my/file"));
    }

    @After
    public void tearDown() throws Exception {
        window.cleanUp();
    }
}
