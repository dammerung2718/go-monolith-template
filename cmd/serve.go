package cmd

import (
	"fmt"
	"template/cfg"
	"template/internal/health"

	"github.com/labstack/echo/v4"
	"github.com/mbndr/figlet4go"
	"github.com/spf13/cobra"
	echoSwagger "github.com/swaggo/echo-swagger"

	_ "template/docs" // swaggo generated package
)

// @title Template API
// @description This is a sample server for a template API.

// @host localhost:3000

var serveCmd = &cobra.Command{
	Use:   "serve",
	Short: "Starts a server",
	Long:  ``,
	Run: func(cmd *cobra.Command, args []string) {
		e := echo.New()
		e.HideBanner = true

		// config
		cfg := cfg.MakeEnvConfig()

		// router
		e.GET("/swagger/*", echoSwagger.WrapHandler)
		health.MakeRouter(e)

		// banner
		ascii := figlet4go.NewAsciiRender()
		options := figlet4go.NewRenderOptions()
		options.FontName = "larry3d"
		color, err := figlet4go.NewTrueColorFromHexString("03A062")
		if err != nil {
			panic(err)
		}
		options.FontColor = []figlet4go.Color{color}
		renderStr, _ := ascii.RenderOpts(cfg.ProjectName, options)
		fmt.Println(renderStr)

		// start server
		e.Logger.Fatal(e.Start(":3000"))
	},
}

func init() {
	rootCmd.AddCommand(serveCmd)
}
