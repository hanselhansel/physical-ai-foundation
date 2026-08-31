# Compute setup decision

Date: 2026-08-31

## Decision

No cloud GPU rental for this sprint. Development runs locally on the Mac using Docker.

## Rationale

The sprint focuses on product management, deployment, and solutions engineering for warehouse/logistics Physical AI. It does not require training robot-learning policies, which is the main use case for a cloud GPU.

- GPU training is not in scope.
- Isaac Sim can be used at a scenario level later, but a full Linux GPU environment is not needed now.
- ROS 2 and middleware/integration work run comfortably in a local Docker container.

## Tooling

- Docker Desktop on Mac.
- ROS 2 Humble container in `warehouse-deployment/docker/ros2-humble/`.
- No persistent cloud instance.

## Revisit when

- We add a robot-learning project.
- We need to run heavy Isaac Sim training or rendering.
- A local GPU workstation becomes available.
