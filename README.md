# UpNow - Adaptive Sleep Alarm App

## Overview

**UpNow** is an iOS alarm app designed to help you wake up more effectively by generating novel and dynamic alarm sounds. Instead of relying on the same repetitive alarm sounds, UpNow uses machine learning to create personalized, non-repeating melodies that adapt over time to improve wakefulness. The app incorporates Google’s **Magenta** music generation model to dynamically generate alarm melodies.

### Key Features

- **Dynamic Alarm Sounds**: Alarm sounds are generated dynamically using a server running the Magenta `attention_rnn` model.
- **Adaptive Waking**: The app tracks snooze behavior and adjusts the generated sounds to help users wake up more effectively.
- **Custom Alarms**: Users can set multiple alarms, configure them to repeat on specific days or intervals (daily, weekly, monthly), and customize the sound generated for each alarm.
- **Audio Playback**: Generated MIDI files are downloaded from the server, converted to audio, and played when the alarm goes off.
- **Simple UI**: The app interface is minimalistic, making it easy to set and manage alarms, download melodies, and handle alarm triggers.

## System Requirements

- iOS 16.0 or later
- A GCP VM instance running Magenta
- Static IP for your server (or replace with your personal IP)

## Setting Up Magenta on GCP

To run the Magenta model on your GCP server, follow these steps:

### 1. Set up a GCP VM instance

1. Go to the Google Cloud Console.
2. Create a new Compute Engine VM instance. Use the following specifications:
   - **Machine Type**: `n1-standard-1` (1 vCPU, 3.75 GB memory)
   - **Boot Disk**: Ubuntu 20.04 LTS
   - **Disk Size**: 50GB
3. Enable the HTTP and HTTPS traffic options under the **Firewall** settings.
4. Assign a **Static IP** to your VM by going to **VPC Network > External IP Addresses** and reserving an external IP for your instance.

