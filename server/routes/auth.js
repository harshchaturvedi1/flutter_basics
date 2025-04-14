const express = require("express");
const jwt = require("jsonwebtoken");
const router = express.Router();

/**
 * Social Authentication endpoint
 * @route POST /auth/social
 */
router.post("/social", async (req, res) => {
  try {
    const { provider, token, email, name, providerId } = req.body;

    console.log("[AUTH] Social login attempt:", { provider, email });

    if (!provider || !token || !email) {
      return res.status(400).json({
        success: false,
        error: {
          code: "MISSING_FIELDS",
          message: "Provider, token and email are required",
        },
      });
    }

    // Mock user creation/login
    // In production, verify the token with Google/Apple
    const mockUser = {
      id: providerId || "social_123",
      email,
      name: name || "Social User",
      provider,
      role: "user",
    };

    const jwtToken = jwt.sign(
      { user: mockUser },
      process.env.JWT_SECRET || "secret",
      { expiresIn: "24h" }
    );

    res.json({
      success: true,
      data: {
        token: jwtToken,
        user: mockUser,
      },
    });
  } catch (error) {
    console.error("[AUTH] Social login error:", error);
    res.status(500).json({
      success: false,
      error: {
        code: "SERVER_ERROR",
        message: "An error occurred during social authentication",
      },
    });
  }
});

/**
 * Login endpoint that generates JWT token
 * @route POST /login
 * @param {string} email - User's email
 * @param {string} phone - User's phone number
 * @returns {Object} Response with JWT token if successful
 */
router.post("/login", async (req, res) => {
  try {
    console.log("[AUTH] Login attempt");
    const { email, phone } = req.body;
    // "REDACTED" is used to hide sensitive data like phone numbers from logs
    // while still showing that a value was present
    console.log("[AUTH] Login credentials:", { email, phone: "REDACTED" });

    // Validate required fields
    if (!email || !phone) {
      console.warn("[AUTH] Missing required fields:", {
        email: !email,
        phone: !phone,
      });
      return res.status(400).json({
        success: false,
        error: {
          code: "MISSING_FIELDS",
          message: "Email and phone are required",
        },
      });
    }

    // Mock user authentication
    // In a real app, this would validate against a database
    const mockUser = {
      id: "123",
      email: email,
      phone: phone,
      role: "user",
      name: "Mock User",
    };
    console.log("[AUTH] User authenticated:", { userId: mockUser.id });

    // Generate JWT token
    const token = jwt.sign(
      { user: mockUser },
      process.env.JWT_SECRET || "secret",
      {
        expiresIn: "24h",
      }
    );
    console.log("[AUTH] JWT token generated for user:", {
      userId: mockUser.id,
    });

    res.json({
      success: true,
      data: {
        token,
        user: mockUser,
      },
    });
    console.log("[AUTH] Login successful for user:", { userId: mockUser.id });
  } catch (error) {
    console.error("[AUTH] Login error:", error);
    res.status(500).json({
      success: false,
      error: {
        code: "SERVER_ERROR",
        message: "An error occurred while processing your request",
      },
    });
  }
});

module.exports = router;
