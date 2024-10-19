{
  lib,
  config,
  pkgs,
  ...
}:
let
  primaryMonitor = lib.head (lib.filter (m: m.primary) config.monitors);

  toggleMonitors = pkgs.writeShellApplication {
    name = "toggleMonitors";
    text = ''
      #!/bin/bash

      # Function to get all monitor names
      get_all_monitors() {
          hyprctl monitors -j | jq -r '.[].name'
      }

      # Function to check if all monitors are on
      all_monitors_on() {
          for monitor in $(get_all_monitors); do
              state=$(hyprctl monitors -j | jq -r ".[] | select(.name == \"$monitor\") | .dpmsStatus")
              if [ "$state" != "true" ]; then
                  return 1
              fi
          done
          return 0
      }

      # Main logic
      if all_monitors_on; then
          # If all monitors are on, put all except primary into standby
          for monitor in $(get_all_monitors); do
             hyprctl dispatch dpms standby "$monitor"
          done
          echo "All monitors are now in standby mode."
      else
          # If not all monitors are on, turn them all on
          for monitor in $(get_all_monitors); do
              hyprctl dispatch dpms on "$monitor"
          done
          echo "All monitors are now on."
      fi    '';
  };

  #dpms standby seems to be working but if monitor wakeup is too sensitive for gaming, can try suspend or off instead
  toggleMonitorsNonPrimary = pkgs.writeShellApplication {
    name = "toggleMonitorsNonPrimary";
    text = ''
      #!/bin/bash

      # Define your primary monitor (the one you want to keep on)
      PRIMARY_MONITOR="${primaryMonitor.name}"  # Replace with your primary monitor name

      # Function to get all monitor names
      get_all_monitors() {
          hyprctl monitors -j | jq -r '.[].name'
      }

      # Function to check if all monitors are on
      all_monitors_on() {
          for monitor in $(get_all_monitors); do
              state=$(hyprctl monitors -j | jq -r ".[] | select(.name == \"$monitor\") | .dpmsStatus")
              if [ "$state" != "true" ]; then
                  return 1
              fi
          done
          return 0
      }

      # Main logic
      if all_monitors_on; then
          # If all monitors are on, put all except primary into standby
          for monitor in $(get_all_monitors); do
              if [ "$monitor" != "$PRIMARY_MONITOR" ]; then
                  hyprctl dispatch dpms standby "$monitor"
              fi
          done
          echo "All monitors except $PRIMARY_MONITOR are now in standby mode."
      else
          # If not all monitors are on, turn them all on
          for monitor in $(get_all_monitors); do
              hyprctl dispatch dpms on "$monitor"
          done
          echo "All monitors are now on."
      fi    '';
  };
in
{
  home.packages = [
    toggleMonitors
    toggleMonitorsNonPrimary
  ];
}
