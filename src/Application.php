<?php

namespace GoldenGoose;

use zesk\Application as ApplicationBase;
use zesk\Request;

class Application extends ApplicationBase {

	/**
	 * @return void
	 * @throws \zesk\Exception\ClassNotFound
	 * @throws \zesk\Exception\SemanticsException
	 */
	protected function afterConfigure(): void
	{
		die(__FILE__);
		$this->router->addRoute(".", [
			"method" => [
				$this,
				"homeHanlder",
			],
		]);
	}

	public function homeHandler(Request $request)
	{
		echo "Hello world!";
	}
}
