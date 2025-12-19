
class ManipulatorUR: ManipulatorSerial {
    var inverseKinematics: URInverseKinematics

    override public init?() {
        return nil
    }

    override init?(links: [any KinematicLinkProtocol]) {

        // Initialize IK calculator if we have 6 DH links
        guard links.count == 6,
            let link1 = links[0] as? KinematicLinkDH,
            let link2 = links[1] as? KinematicLinkDH,
            let link3 = links[2] as? KinematicLinkDH,
            let link4 = links[3] as? KinematicLinkDH,
            let link5 = links[4] as? KinematicLinkDH,
            let link6 = links[5] as? KinematicLinkDH
        else {
            return nil 
        }

        self.inverseKinematics = URInverseKinematics(
            link1: link1,
            link2: link2,
            link3: link3,
            link4: link4,
            link5: link5,
            link6: link6
        )
        super.init(links: links)
    }
}

class ManipulatorUR10e: ManipulatorUR {
    /// Initializes a new `ManipulatorUR10e`.
    override public init?() {
        super.init(links: [
            KinematicLinkDH(

                a: 0.0,
                alpha: Float.pi / 2,
                d: 0.1807,
                mass: 7.369,
                centerOfMass: [0.021, 0.000, 0.027],
                inertiaMatrix: [0.0341, 0.0000, -0.0043, 0.0000, 0.0353, 0.0001, -0.0043, 0.0001, 0.0216]
            ),
            KinematicLinkDH(
                a: -0.6127,
                alpha: 0.0,
                d: 0.0,
                mass: 13.051,
                centerOfMass: [0.38, 0.000, 0.158],
                inertiaMatrix: [0.0281, 0.0001, -0.0156, 0.0001, 0.7707, 0.0000, -0.0156, 0.0000, 0.7694]
            ),
            KinematicLinkDH(
                a: -0.57155,
                alpha: 0.0,
                d: 0.0,
                mass: 3.989,
                centerOfMass: [0.24, 0.000, 0.068],
                inertiaMatrix: [0.0101, 0.0001, 0.0092, 0.0001, 0.3093, 0.0000, 0.0092, 0.0000, 0.3065]
            ),
            KinematicLinkDH(
                a: 0.0,
                alpha: Float.pi / 2,
                d: 0.17415,
                mass: 2.1,
                centerOfMass: [0.000, 0.007, 0.018],
                inertiaMatrix: [0.0030, -0.0000, -0.0000, -0.0000, 0.0022, -0.0002, -0.0000, -0.0002, 0.0026]
            ),
            KinematicLinkDH(
                a: 0.0,
                alpha: -Float.pi / 2,
                d: 0.11985,
                mass: 1.98,
                centerOfMass: [0.000, 0.007, 0.018],
                inertiaMatrix: [0.0030, -0.0000, -0.0000, -0.0000, 0.0022, -0.0002, -0.0000, -0.0002, 0.0026]
            ),
            KinematicLinkDH(
                a: 0.0,
                alpha: 0.0,
                d: 0.11655,
                mass: 0.615,
                centerOfMass: [0, 0, -0.026],
                inertiaMatrix: [0.0000, 0.0000, -0.0000, 0.0000, 0.0004, 0.0000, -0.0000, 0.0000, 0.0003]
            ),
        ])
    }
}

class ManipulatorUR12e: ManipulatorUR {
    /// Initializes a new `ManipulatorUR12e`.
    override public init?() {
        super.init(links: [
            KinematicLinkDH(
                a: 0.0,
                alpha: Float.pi / 2,
                d: 0.1807,
                mass: 7.369,
                centerOfMass: [0.021, 0.000, 0.027],
                inertiaMatrix: [0.0341, 0.0000, -0.0043, 0.0000, 0.0353, 0.0001, -0.0043, 0.0001, 0.0216]
            ),
            KinematicLinkDH(
                a: -0.6127,
                alpha: 0.0,
                d: 0.0,
                mass: 13.051,
                centerOfMass: [0.38, 0.000, 0.158],
                inertiaMatrix: [0.0281, 0.0001, -0.0156, 0.0001, 0.7707, 0.0000, -0.0156, 0.0000, 0.7694]
            ),
            KinematicLinkDH(
                a: -0.57155,
                alpha: 0.0,
                d: 0.0,
                mass: 3.989,
                centerOfMass: [0.24, 0.000, 0.068],
                inertiaMatrix: [0.0101, 0.0001, 0.0092, 0.0001, 0.3093, 0.0000, 0.0092, 0.0000, 0.3065]
            ),
            KinematicLinkDH(
                a: 0.0,
                alpha: Float.pi / 2,
                d: 0.17415,
                mass: 2.1,
                centerOfMass: [0.000, 0.007, 0.018],
                inertiaMatrix: [0.0030, -0.0000, -0.0000, -0.0000, 0.0022, -0.0002, -0.0000, -0.0002, 0.0026]
            ),
            KinematicLinkDH(
                a: 0.0,
                alpha: -Float.pi / 2,
                d: 0.11985,
                mass: 1.98,
                centerOfMass: [0.000, 0.007, 0.018],
                inertiaMatrix: [0.0030, -0.0000, -0.0000, -0.0000, 0.0022, -0.0002, -0.0000, -0.0002, 0.0026]
            ),
            KinematicLinkDH(
                a: 0.0,
                alpha: 0.0,
                d: 0.11655,
                mass: 0.615,
                centerOfMass: [0, 0, -0.026],
                inertiaMatrix: [0.0000, 0.0000, -0.0000, 0.0000, 0.0004, 0.0000, -0.0000, 0.0000, 0.0003]
            ),
        ])
    }
}

class ManipulatorUR15: ManipulatorUR {
    /// Initializes a new `ManipulatorUR15e`.
    override public init?() {
        super.init(links: [
            KinematicLinkDH(
                a: 0.0,
                alpha: Float.pi / 2,
                d: 0.2186,
                mass: 9.9883,
                centerOfMass: [0.000024, -0.033309, 0.025304],
                inertiaMatrix: [
                    0.051334, 0.000025, -0.000016, 0.000025, 0.047702, 0.008805, -0.000016, 0.008805, 0.034263,
                ]
            ),
            KinematicLinkDH(
                a: -0.6475,
                alpha: 0.0,
                d: 0.0,
                mass: 14.9255,
                centerOfMass: [0.419009, -0.000083, 0.192787],
                inertiaMatrix: [
                    0.048202, 0.000232, -0.032135, 0.000232, 1.188499, -0.000017, -0.032135, -0.000017, 1.182771,
                ]
            ),
            KinematicLinkDH(
                a: -0.5164,
                alpha: 0.0,
                d: 0.0,
                mass: 6.1015,
                centerOfMass: [0.305471, 0.000019, 0.070552],
                inertiaMatrix: [
                    0.018481, -0.000005, 0.013601, -0.000005, 0.303502, 0.000003, 0.013601, 0.000003, 0.296843,
                ]
            ),
            KinematicLinkDH(
                a: 0.0,
                alpha: Float.pi / 2,
                d: 0.1824,
                mass: 2.0890,
                centerOfMass: [0.000025, -0.019695, 0.016413],
                inertiaMatrix: [
                    0.004339, 0.000019, 0.000001, 0.000019, 0.002548, 0.000706, 0.000001, 0.000706, 0.003912,
                ]
            ),
            KinematicLinkDH(
                a: 0.0,
                alpha: -Float.pi / 2,
                d: 0.1361,
                mass: 2.0869,
                centerOfMass: [0.000025, 0.019960, 0.015886],
                inertiaMatrix: [
                    0.004288, 0.000017, -0.000003, 0.000017, 0.002566, -0.000716, -0.000003, -0.000716, 0.003927,
                ]
            ),
            KinematicLinkDH(
                a: 0.0,
                alpha: 0.0,
                d: 0.1434,
                mass: 1.0666,
                centerOfMass: [-0.000018, -0.000112, -0.053397],
                inertiaMatrix: [
                    0.001406, -0.000003, 0.000010, -0.000003, 0.001404, -0.000024, 0.000010, -0.000024, 0.001002,
                ]
            ),
        ])
    }
}

class ManipulatorUR20: ManipulatorUR {
    /// Initializes a new `ManipulatorUR20e`.
    override public init?() {
        super.init(links: [
            KinematicLinkDH(
                a: 0.0,
                alpha: Float.pi / 2,
                d: 0.2363,
                mass: 16.343,
                centerOfMass: [0, -0.0610, 0.0062],
                inertiaMatrix: [0.0887, -0.0001, -0.0001, -0.0001, 0.0763, 0.0072, -0.0001, 0.0072, 0.0842]
            ),
            KinematicLinkDH(
                a: -0.8620,
                alpha: 0.0,
                d: 0.0,
                mass: 29.632,
                centerOfMass: [0.5226, 0, 0.2098],
                inertiaMatrix: [0.1467, 0.0002, -0.0516, 0.0002, 4.6659, 0.0000, -0.0516, 0.0000, 4.6348]
            ),
            KinematicLinkDH(
                a: -0.7287,
                alpha: 0.0,
                d: 0.0,
                mass: 7.879,
                centerOfMass: [0.3234, 0, 0.0604],
                inertiaMatrix: [0.0261, -0.0001, -0.0290, -0.0001, 0.7576, -0.0000, -0.0290, -0.0000, 0.7533]
            ),
            KinematicLinkDH(
                a: 0.0,
                alpha: Float.pi / 2,
                d: 0.2010,
                mass: 3.054,
                centerOfMass: [0, -0.0026, 0.0393],
                inertiaMatrix: [0.0056, -0.0000, -0.0000, -0.0000, 0.0054, 0.0004, -0.0000, 0.0004, 0.0040]
            ),
            KinematicLinkDH(
                a: 0.0,
                alpha: -Float.pi / 2,
                d: 0.1593,
                mass: 3.126,
                centerOfMass: [0, 0.0024, 0.0379],
                inertiaMatrix: [0.0059, -0.0000, 0.0000, -0.0000, 0.0058, -0.0004, 0.0000, -0.0004, 0.0043]
            ),
            KinematicLinkDH(
                a: 0.0,
                alpha: 0.0,
                d: 0.1543,
                mass: 0.846,
                centerOfMass: [0, -0.0003, -0.0318],
                inertiaMatrix: [0.0009, 0.0000, 0.0000, 0.0000, 0.0009, 0.0000, 0.0000, 0.0000, 0.0012]
            ),
        ])
    }
}

class ManipulatorUR30: ManipulatorUR {
    /// Initializes a new `ManipulatorUR30`.
    override public init?() {
        super.init(links: [
            KinematicLinkDH(
                a: 0.0,
                alpha: Float.pi / 2,
                d: 0.2363,
                mass: 16.343,
                centerOfMass: [-0.0001, -0.0600, 0.0069],
                inertiaMatrix: [0.0883, -0.0001, -0.0001, -0.0001, 0.0764, 0.0076, -0.0001, 0.0076, 0.0830]
            ),
            KinematicLinkDH(
                a: -0.6370,
                alpha: 0.0,
                d: 0.0,
                mass: 28.542,
                centerOfMass: [0.3894, 0, 0.2103],
                inertiaMatrix: [0.1379, 0.0001, -0.0451, 0.0001, 2.5013, -0.0000, -0.0451, -0.0000, 2.4751]
            ),
            KinematicLinkDH(
                a: -0.5037,
                alpha: 0.0,
                d: 0.0,
                mass: 7.156,
                centerOfMass: [0.2257, 0, 0.0629],
                inertiaMatrix: [0.0236, 0.0000, -0.0168, 0.0009, 0.3388, 0.0001, -0.0168, 0.0001, 0.3353]
            ),
            KinematicLinkDH(
                a: 0.0,
                alpha: Float.pi / 2,
                d: 0.2010,
                mass: 3.054,
                centerOfMass: [0, -0.0048, 0.0353],
                inertiaMatrix: [0.0056, 0.0000, 0.0000, 0.0000, 0.0051, 0.0006, 0.0000, 0.0006, 0.0043]
            ),
            KinematicLinkDH(
                a: 0.0,
                alpha: -Float.pi / 2,
                d: 0.1593,
                mass: 3.126,
                centerOfMass: [0, 0.0046, 0.0341],
                inertiaMatrix: [0.0060, 0.0000, 0.0000, 0.0000, 0.0056, -0.0006, 0.0000, -0.0006, 0.0046]
            ),
            KinematicLinkDH(
                a: 0.0,
                alpha: 0.0,
                d: 0.1543,
                mass: 0.926,
                centerOfMass: [0, 0, -0.0293],
                inertiaMatrix: [0.0009, 0.0000, 0.0000, 0.0000, 0.0009, 0.0000, 0.0000, 0.0000, 0.0012]
            ),
        ])
    }
}

class ManipulatorUR3e: ManipulatorUR {
    /// Initializes a new `ManipulatorUR30`.
    override public init?() {
        super.init(links: [
            KinematicLinkDH(a: 0.0, alpha: Float.pi / 2, d: 0.15185, mass: 1.98, centerOfMass: [0, -0.02, 0]),
            KinematicLinkDH(a: -0.24355, alpha: 0.0, d: 0.0, mass: 3.4445, centerOfMass: [0.13, 0, 0.1157]),
            KinematicLinkDH(a: -0.2132, alpha: 0.0, d: 0.0, mass: 1.437, centerOfMass: [0.05, 0, 0.0238]),
            KinematicLinkDH(a: 0.0, alpha: Float.pi / 2, d: 0.13105, mass: 0.871, centerOfMass: [0, 0, 0.01]),
            KinematicLinkDH(a: 0.0, alpha: -Float.pi / 2, d: 0.08535, mass: 0.805, centerOfMass: [0, 0, 0.01]),
            KinematicLinkDH(a: 0.0, alpha: 0.0, d: 0.0921, mass: 0.261, centerOfMass: [0, 0, -0.02]),
        ])
    }
}

class ManipulatorUR5e: ManipulatorUR {
    /// Initializes a new `ManipulatorUR5e`.
    override public init?() {
        super.init(links: [
            KinematicLinkDH(
                a: 0.0,
                alpha: Float.pi / 2,
                d: 0.1625,
                mass: 3.761,
                centerOfMass: [0, -0.02561, 0.00193]
            ),
            KinematicLinkDH(a: -0.425, alpha: 0.0, d: 0.0, mass: 8.058, centerOfMass: [0.2125, 0, 0.11336]),
            KinematicLinkDH(a: -0.3922, alpha: 0.0, d: 0.0, mass: 2.846, centerOfMass: [0.15, 0.0, 0.0265]),
            KinematicLinkDH(a: 0.0, alpha: Float.pi / 2, d: 0.1333, mass: 1.37, centerOfMass: [0, -0.0018, 0.01634]),
            KinematicLinkDH(a: 0.0, alpha: -Float.pi / 2, d: 0.0997, mass: 1.3, centerOfMass: [0, 0.0018, 0.01634]),
            KinematicLinkDH(a: 0.0, alpha: 0.0, d: 0.0996, mass: 0.365, centerOfMass: [0, 0, -0.001159]),
        ])
    }
}

class ManipulatorUR7e: ManipulatorUR {
    /// Initializes a new `ManipulatorUR7e`.
    override public init?() {
        super.init(links: [
            KinematicLinkDH(
                a: 0.0,
                alpha: Float.pi / 2,
                d: 0.1625,
                mass: 3.761,
                centerOfMass: [0, -0.02561, 0.00193]
            ),
            KinematicLinkDH(a: -0.425, alpha: 0.0, d: 0.0, mass: 8.058, centerOfMass: [0.2125, 0, 0.11336]),
            KinematicLinkDH(a: -0.3922, alpha: 0.0, d: 0.0, mass: 2.846, centerOfMass: [0.15, 0.0, 0.0265]),
            KinematicLinkDH(a: 0.0, alpha: Float.pi / 2, d: 0.1333, mass: 1.37, centerOfMass: [0, -0.0018, 0.01634]),
            KinematicLinkDH(a: 0.0, alpha: -Float.pi / 2, d: 0.0997, mass: 1.3, centerOfMass: [0, 0.0018, 0.01634]),
            KinematicLinkDH(a: 0.0, alpha: 0.0, d: 0.0996, mass: 0.365, centerOfMass: [0, 0, -0.001159]),
        ])
    }
}

class ManipulatorUR16e: ManipulatorUR {
    /// Initializes a new `ManipulatorUR16e`.
    override public init?() {
        super.init(links: [
            KinematicLinkDH(
                a: 0.0,
                alpha: Float.pi / 2,
                d: 0.1807,
                mass: 7.369,
                centerOfMass: [0.000, -0.016, 0.030]
            ),
            KinematicLinkDH(a: -0.4784, alpha: 0.0, d: 0.0, mass: 10.450, centerOfMass: [0.302, 0.000, 0.160]),
            KinematicLinkDH(a: -0.36, alpha: 0.0, d: 0.0, mass: 4.321, centerOfMass: [0.194, 0.000, 0.065]),
            KinematicLinkDH(
                a: 0.0,
                alpha: Float.pi / 2,
                d: 0.17415,
                mass: 2.180,
                centerOfMass: [0.000, -0.009, 0.011]
            ),
            KinematicLinkDH(
                a: 0.0,
                alpha: -Float.pi / 2,
                d: 0.11985,
                mass: 2.033,
                centerOfMass: [0.000, 0.018, 0.012]
            ),
            KinematicLinkDH(a: 0.0, alpha: 0.0, d: 0.11655, mass: 0.907, centerOfMass: [0, 0, -0.044]),
        ])
    }
}

class ManipulatorUR3: ManipulatorUR {
    /// Initializes a new `ManipulatorUR3`.
    override public init?() {
        super.init(links: [
            KinematicLinkDH(a: 0.0, alpha: Float.pi / 2, d: 0.1519, mass: 2, centerOfMass: [0, -0.02, 0]),
            KinematicLinkDH(a: -0.24365, alpha: 0.0, d: 0.0, mass: 3.42, centerOfMass: [0.13, 0, 0.1157]),
            KinematicLinkDH(a: -0.21325, alpha: 0.0, d: 0.0, mass: 1.26, centerOfMass: [0.05, 0, 0.0238]),
            KinematicLinkDH(a: 0.0, alpha: Float.pi / 2, d: 0.11235, mass: 0.8, centerOfMass: [0, 0, 0.01]),
            KinematicLinkDH(a: 0.0, alpha: -Float.pi / 2, d: 0.08535, mass: 0.8, centerOfMass: [0, 0, 0.01]),
            KinematicLinkDH(a: 0.0, alpha: 0.0, d: 0.0819, mass: 0.35, centerOfMass: [0, 0, -0.02]),
        ])
    }
}

/// Represents the UR5 manipulator, a specific implementation of the UR manipulator series.
/// This class inherits from `ManipulatorUR` and initializes the UR5 manipulator with its specific
/// kinematic links and parameters.
class ManipulatorUR5: ManipulatorUR {
    /// Initializes a new `ManipulatorUR5`.
    override public init?() {
        super.init(links: [
            KinematicLinkDH(
                a: 0.0,
                alpha: Float.pi / 2,
                d: 0.089159,
                mass: 3.7,
                centerOfMass: [0, -0.02561, 0.00193]
            ),
            KinematicLinkDH(a: -0.425, alpha: 0.0, d: 0.0, mass: 8.393, centerOfMass: [0.2125, 0, 0.11336]),
            KinematicLinkDH(a: -0.39225, alpha: 0.0, d: 0.0, mass: 2.33, centerOfMass: [0.15, 0.0, 0.0265]),
            KinematicLinkDH(
                a: 0.0,
                alpha: Float.pi / 2,
                d: 0.10915,
                mass: 1.219,
                centerOfMass: [0, -0.0018, 0.01634]
            ),
            KinematicLinkDH(
                a: 0.0,
                alpha: -Float.pi / 2,
                d: 0.09465,
                mass: 1.219,
                centerOfMass: [0, 0.0018, 0.01634]
            ),
            KinematicLinkDH(a: 0.0, alpha: 0.0, d: 0.0823, mass: 0.1879, centerOfMass: [0, 0, -0.001159]),
        ])
    }
}
