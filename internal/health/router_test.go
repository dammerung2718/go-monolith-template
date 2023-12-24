package health

import (
	"net/http/httptest"
	"os"
	"testing"

	"github.com/labstack/echo/v4"
	"github.com/stretchr/testify/require"
)

var e *echo.Echo

func TestMain(m *testing.M) {
	e = echo.New()
	MakeRouter(e)
	os.Exit(m.Run())
}

func TestHealthHandler(t *testing.T) {
	req := httptest.NewRequest("GET", "/health", nil)
	rec := httptest.NewRecorder()
	c := e.NewContext(req, rec)

	err := HealthHandler(c)
	require.NoError(t, err)

	require.Equal(t, 200, rec.Code)
	require.Equal(t, "{\"status\":\"ok\"}\n", rec.Body.String())
}
