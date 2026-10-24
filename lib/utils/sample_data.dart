import 'package:flutter/material.dart';
import '../models/equipment.dart';

const List<Equipment> equipmentList = [
  Equipment(
    name: 'Projector',
    category: 'Audio-Visual',
    available: 5,
    icon: Icons.videocam_outlined,
    description:
        'Portable projector for presentations, seminars, meetings, and events.',
    imageUrl:
        'https://images.unsplash.com/photo-1478720568477-152d9b164e26?w=600',
  ),
  Equipment(
    name: 'Laptop',
    category: 'Computing',
    available: 8,
    icon: Icons.laptop_mac_outlined,
    description:
        'University laptop for presentations, workshops, and organization activities.',
    imageUrl:
        'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=600',
  ),
  Equipment(
    name: 'Microphone',
    category: 'Audio',
    available: 12,
    icon: Icons.mic_none_outlined,
    description: 'Wired microphone for programs, meetings, and campus events.',
    imageUrl:
        'https://images.unsplash.com/photo-1590602847861-f357a9332bbc?w=600',
  ),
  Equipment(
    name: 'Speaker',
    category: 'Audio',
    available: 6,
    icon: Icons.speaker_group_outlined,
    description: 'Portable speaker system for university programs and events.',
    imageUrl:
        'https://images.unsplash.com/photo-1608043152269-423dbba4e7e1?w=600',
  ),
  Equipment(
    name: 'Extension Cord',
    category: 'Electrical',
    available: 15,
    icon: Icons.power_outlined,
    description: 'Extension cord for approved university activities.',
    imageUrl:
        'https://images.unsplash.com/photo-1601999009162-25d5f4d3f4b8?w=600',
  ),
  Equipment(
    name: 'HDMI Cable',
    category: 'Accessories',
    available: 10,
    icon: Icons.cable_outlined,
    description: 'HDMI cable for connecting laptops, projectors, and displays.',
    imageUrl:
        'https://images.unsplash.com/photo-1588872657578-7efd1f1555ed?w=600',
  ),
];
