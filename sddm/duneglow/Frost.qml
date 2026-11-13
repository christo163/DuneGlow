// Real background blur for a glass panel. Needs Qt 6.5+ (QtQuick.Effects).
// If this file fails to load (older Qt), GlassPanel keeps working with a plain tinted look.
import QtQuick 2.15
import QtQuick.Effects

Item {
    id: frost
    property Item backdrop: null
    property Item host: null
    property real cornerRadius: 22

    // Re-evaluated when the panel moves or the screen resizes.
    property real tick: host && backdrop ? (host.x + host.y + host.width + host.height + backdrop.width + backdrop.height + (host.parent ? host.parent.x + host.parent.y : 0)) : 0

    ShaderEffectSource {
        id: snap
        visible: false
        sourceItem: frost.backdrop
        sourceRect: {
            var t = frost.tick
            if (!frost.host || !frost.backdrop)
                return Qt.rect(0, 0, 1, 1)
            var p = frost.host.mapToItem(frost.backdrop, 0, 0)
            return Qt.rect(p.x, p.y, frost.host.width, frost.host.height)
        }
    }

    Item {
        id: maskItem
        anchors.fill: parent
        visible: false
        layer.enabled: true
        Rectangle { anchors.fill: parent; radius: frost.cornerRadius; color: "black" }
    }

    MultiEffect {
        anchors.fill: parent
        source: snap
        blurEnabled: true
        blurMax: 48
        blur: 1.0
        saturation: 0.25
        maskEnabled: true
        maskSource: maskItem
    }
}
