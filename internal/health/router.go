package health

import "github.com/labstack/echo/v4"

func MakeRouter(e *echo.Echo) {
	e.GET("/health", HealthHandler)
}

// @Summary Health check
// @Description Checks if the server is up and running
// @Tags health
// @Accept json
// @Produce json
// @Success 200 {object} map[string]string
// @Router /health [get]
func HealthHandler(c echo.Context) error {
	return c.JSON(200, map[string]string{"status": "ok"})
}
