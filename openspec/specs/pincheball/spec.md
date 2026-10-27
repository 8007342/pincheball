# Pincheball experience

## Purpose

This specification records the intended game. The initial runnable scaffold implements only a subset; see plan/roadmap.md. Density, camera and ballistic parameters in docs/design are proposals awaiting evaluation.

## Requirements

### Requirement: One climb with no scoring system
The game SHALL represent the hiker's struggle with one abstract ball, with no multiball, score, lives or checkpoints. Reaching the trailhead basin after falling SHALL restart the run and reset its progress. The terrain SHALL be procedurally composed with a finite summit and SHALL target 5–15 minutes of successful active play after balancing.

#### Scenario: Fall to the base
- **GIVEN** a ball has climbed above the trailhead
- **WHEN** it falls into the base restart region
- **THEN** the run resets to its initial gameplay state without lives, checkpoint rescue or score

### Requirement: Cinematic beginning and persistent ending
The game SHALL follow landing → cinematic intro → uphill gameplay → cinematic outro. The landing SHALL show a hiker seated on a rock swinging their feet above a valley near water and flat land. A tap anywhere SHALL begin the intro once. The outro SHALL remain loaded with an animated summit view. A delayed corner Restart button SHALL reload the page; background taps SHALL NOT restart.

#### Scenario: Summit rest
- **GIVEN** the summit objective was completed
- **WHEN** the cinematic outro finishes
- **THEN** the hiker and majestic animated grand view remain visible indefinitely, recalling landmarks encountered during the climb
- **AND** a small Restart action appears after a few seconds and reloads the page when selected

### Requirement: Two sides control all corresponding flippers
Left-half touch and Left arrow SHALL activate the left flippers, and right-half touch and Right arrow SHALL activate the right flippers throughout the active simulation region. Multiple flippers per side SHALL be supported. Simultaneous inputs SHALL work, cancellation or focus loss SHALL release inputs, and keyboard repeat SHALL NOT create extra impulses.

#### Scenario: Multiple active flippers
- **GIVEN** two left flippers and one right flipper are active
- **WHEN** the player presses Left arrow
- **THEN** both left flippers activate while the right flipper retains its own input state

### Requirement: Connected procedural ascent and readable camera
The world SHALL combine frequent flippers, recovery funnels, challenging obstacles and optional themed trick shots such as springs, lifts and hollow logs. Generation SHALL preserve traversable ascent connections, valid side boundaries, downward continuity and a unique reachable summit receiver. The camera SHALL retain the ball and provide readable upcoming receivers without changing physics according to viewport size.

#### Scenario: Winning reception
- **GIVEN** the ball is near the summit
- **WHEN** it enters the summit receiver from above and settles
- **THEN** gameplay completes exactly once and hands off to the outro
- **AND** merely crossing the summit altitude does not complete the game

### Requirement: A living mountain with progressive scenery
Scenery SHALL transition continuously from valley water and flats through forest and alpine terrain to a snowy peak piercing clouds. Layered backgrounds and small continuous animations SHALL create depth. Local ball impacts and flipper activity SHALL trigger bounded foliage and wildlife reactions. Decorative detail SHALL preserve ball and receiver visibility. The final view SHALL reconnect the summit to the places encountered during the run.

#### Scenario: Local tree impact
- **GIVEN** a tree with a perched flock is near a ball impact
- **WHEN** the impact exceeds its local response threshold
- **THEN** a bounded flock takes flight and leaves respond
- **AND** nearby animals may flee or later approach with curiosity, including rabbits and deer
- **AND** remote trees and creatures do not all restart the same reaction

### Requirement: Portrait pixel illustration with smooth motion
The game SHALL use pixel illustration with smooth continuous motion and SHALL target portrait mobile proportions. Wider displays SHALL preserve the centered portrait gameplay corridor and use surrounding space for scenery without stretching geometry or exposing additional routes. Cinematics and the summit view SHALL be composed for portrait.

#### Scenario: Wide display framing
- **WHEN** the game is displayed on a wide screen
- **THEN** the portrait gameplay corridor retains its proportions and route visibility
- **AND** scenic margins fill the surrounding space
