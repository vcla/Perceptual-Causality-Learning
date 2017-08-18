Learning Causality from Video
=============================

Introduction
------------

This code implements the theory to learn the Causal And-Or Graph from the paper "Learning Perceptual Causality from Video" by Amy Fire and Song-Chun Zhu, 2016.  The associated paper and data can be found at [http://amyfire.com/projects/learningcausality/](http://amyfire.com/projects/learningcausality/).

This code uses a minimax entropy pursuit alongside heuristics to attribute strong correlations as causal.

Required Data
-------------

Source data consists of detections made in 4 scenes--3 different kinds of doorways (`data/Exp1_output_data_key.txt`, `data/Exp1_output_data3.txt`, `data/Exp1_output_data2.txt`) and 1 office scene (`data/Exp2_output_data.txt`).  Detections were performed by Mingtao Pei.

Workflow
--------

Output for the paper is produced by running the script `LEARNING.m`.  It requires the detections in `data/`.
