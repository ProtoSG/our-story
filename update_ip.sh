#!/bin/bash

echo "🔍 Detectando IPs disponibles..."
echo ""

# Obtener IP WiFi
WIFI_IP=$(ip addr show wlan0 2>/dev/null | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
if [ -n "$WIFI_IP" ]; then
    echo "📡 WiFi (wlan0):        $WIFI_IP"
fi

# Obtener IPs USB
USB_IPS=$(ip addr show enp3s0f4u2 2>/dev/null | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
if [ -n "$USB_IPS" ]; then
    echo "🔌 USB (enp3s0f4u2):"
    i=1
    for ip in $USB_IPS; do
        if [ $i -eq 1 ]; then
            echo "   Primary:   $ip  ⬅️ RECOMENDADA"
            RECOMMENDED_IP="$ip"
        else
            echo "   Secondary: $ip"
        fi
        i=$((i+1))
    done
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Verificar IP actual en el código
CURRENT_IP=$(grep -oP "(?<=baseUrl = 'http://)[^:]+(?=:8080)" our_story_front/lib/core/api/api_constants.dart)
echo "📱 IP actual en Flutter: $CURRENT_IP"

if [ -n "$RECOMMENDED_IP" ] && [ "$CURRENT_IP" != "$RECOMMENDED_IP" ]; then
    echo ""
    echo "⚠️  La IP ha cambiado!"
    echo ""
    read -p "¿Actualizar a $RECOMMENDED_IP? (s/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[SsYy]$ ]]; then
        # Actualizar la IP en el archivo
        sed -i "s|baseUrl = 'http://[0-9.]*:8080'|baseUrl = 'http://$RECOMMENDED_IP:8080'|" our_story_front/lib/core/api/api_constants.dart
        echo "✅ IP actualizada a $RECOMMENDED_IP"
        echo ""
        echo "📋 Ejecuta estos comandos para aplicar los cambios:"
        echo "   cd our_story_front"
        echo "   flutter run"
    else
        echo "❌ Actualización cancelada"
    fi
else
    echo "✅ La IP está actualizada"
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
