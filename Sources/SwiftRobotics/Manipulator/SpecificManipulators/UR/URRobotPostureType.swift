
/// URRobotPostureType.swift
/// This file defines the posture types for UR robots, which are used to describe the configuration of the robot's joints.
/// Each posture type corresponds to a specific arrangement of the robot's shoulder, elbow, and wrist joints.
public enum URRobotPostureType: Int {
    case shoulderLeftElbowUpWristDown = 0
    case shoulderLeftElbowUpWristUp = 1
    case shoulderLeftElbowDownWristDown = 2
    case shoulderLeftElbowDownWristUp = 3
    case shoulderRightElbowDownWristUp = 4
    case shoulderRightElbowDownWristDown = 5
    case shoulderRightElbowUpWristUp = 6
    case shoulderRightElbowUpWristDown = 7

    public var description: String {
        switch self {
        case .shoulderLeftElbowUpWristDown:
            return "Shoulder Left, Elbow Up, Wrist Down"
        case .shoulderLeftElbowUpWristUp:
            return "Shoulder Left, Elbow Up, Wrist Up"
        case .shoulderLeftElbowDownWristDown:
            return "Shoulder Left, Elbow Down, Wrist Down"
        case .shoulderLeftElbowDownWristUp:
            return "Shoulder Left, Elbow Down, Wrist Up"
        case .shoulderRightElbowDownWristUp:
            return "Shoulder Right, Elbow Down, Wrist Up"
        case .shoulderRightElbowDownWristDown:
            return "Shoulder Right, Elbow Down, Wrist Down"
        case .shoulderRightElbowUpWristUp:
            return "Shoulder Right, Elbow Up, Wrist Up"
        case .shoulderRightElbowUpWristDown:
            return "Shoulder Right, Elbow Up, Wrist Down"
        }
    }
}
