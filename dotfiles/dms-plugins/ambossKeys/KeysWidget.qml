import QtQuick
import Quickshell
import qs.Common
import qs.Services
import qs.Widgets
import qs.Modules.Plugins

// Hinweis in der Leiste: ein Klick (oder Super+K) öffnet die Tastenübersicht.
PluginComponent {
    id: root

    pillClickAction: () => {
        Quickshell.execDetached(["dms", "ipc", "call", "keybinds", "toggle", "niri"]);
    }

    horizontalBarPill: Component {
        StyledText {
            text: "SUPER+K // TASTEN"
            font.pixelSize: Theme.fontSizeSmall
            color: Theme.surfaceVariantText
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    verticalBarPill: Component {
        DankIcon {
            name: "keyboard"
            size: Theme.iconSizeSmall
            color: Theme.surfaceVariantText
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }
}
