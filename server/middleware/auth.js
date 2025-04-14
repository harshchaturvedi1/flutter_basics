/**
 * Authentication and Authorization Middleware
 * This module provides middleware functions for handling JWT authentication
 * and role-based authorization in Express applications.
 */

const express = require("express");
const jwt = require("jsonwebtoken");

/**
 * Extracts JWT token from the Authorization header
 * @param {string} authHeader - The Authorization header value
 * @returns {string|null} The JWT token if valid format, null otherwise
 */
function getTokenFromHeader(authHeader) {
  if (!authHeader) return null;
  const [bearer, token] = authHeader.split(" ");
  return bearer === "Bearer" && token ? token : null;
}

/**
 * Verifies and decodes a JWT token
 * @param {string} token - The JWT token to verify
 * @param {string} secret - The secret key used to verify the token
 * @returns {Object|null} The decoded user object if valid, null otherwise
 */
async function verifyToken(token, secret) {
  if (!token) return null;

  try {
    const payload = jwt.verify(token, secret);
    if (!payload?.user) return null;
    return payload.user;
  } catch {
    return null;
  }
}

/**
 * Authentication middleware that verifies JWT tokens
 * Adds the authenticated user object to req.user if successful
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 * @param {Function} next - Express next middleware function
 */
const auth = async (req, res, next) => {
  const token = getTokenFromHeader(req.headers.authorization);
  const user = await verifyToken(token, process.env.JWT_SECRET || "secret");

  if (!user) {
    return res.status(401).json({
      success: false,
      error: {
        code: "UNAUTHORIZED",
        message: "Authentication required",
      },
    });
  }

  req.user = user;
  next();
};

/**
 * Role-based authorization middleware factory
 * Creates middleware that checks if authenticated user has required role
 * @param {string[]} allowedRoles - Array of role names that are allowed access
 * @returns {Function} Express middleware function that checks user roles
 */
const requireRole = (allowedRoles) => {
  return (req, res, next) => {
    const user = req.user;

    if (!user?.role || !allowedRoles.includes(user.role)) {
      return res.status(403).json({
        success: false,
        error: {
          code: "FORBIDDEN",
          message: "You do not have permission to access this resource",
        },
      });
    }

    next();
  };
};

module.exports = {
  auth,
  requireRole,
};
