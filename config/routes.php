<?php

use App\Controller\IndexController;
use Symfony\Component\Routing\Loader\Configurator\RoutingConfigurator;

return static function (RoutingConfigurator $routes) {

    $routes
        ->add('index', '')
        ->controller([IndexController::class, 'index'])
        ->methods(['get']);

};
