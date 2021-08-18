#include <SFML/Graphics.hpp>

int main()
{
  sf::RenderWindow window( sf::VideoMode( 640, 480 ), "Bouncing mushroom!" );

  sf::Texture mushroomTexture;
  mushroomTexture.loadFromFile( "D:\\Dev\\Workspace\\sfml\\resources\\Mushroom.png" );

  sf::Sprite mushroomSprite( mushroomTexture );

  const sf::Vector2u txtSize = mushroomTexture.getSize();
  mushroomSprite.setOrigin( txtSize.x / 2, txtSize.y / 2 );

  sf::Vector2f increment( 0.02f, 0.02f );

  // event handling loop
  while ( window.isOpen() ) {
    sf::Event event;
    while ( window.pollEvent( event ) ) {
      if ( event.type == sf::Event::Closed )
        window.close();
    }

    if ( ( mushroomSprite.getPosition().x + txtSize.x / 2 > window.getSize().x &&
           increment.x > 0 ) ||
         ( mushroomSprite.getPosition().x - txtSize.x / 2 < 0 && increment.x < 0 ) ) {
      // reverse the direction on x axis
      increment.x = -increment.x;
    }

    if ( ( mushroomSprite.getPosition().y + txtSize.y / 2 > window.getSize().y &&
           increment.y > 0 ) ||
         ( mushroomSprite.getPosition().y - txtSize.y / 2 < 0 && increment.y < 0 ) ) {
      // reverse the direction on y axis
      increment.y = -increment.y;
    }

    mushroomSprite.setPosition( mushroomSprite.getPosition() + increment );

    window.clear( sf::Color( 160, 160, 160, 255 ) );  // dark gray
    window.draw( mushroomSprite );
    window.display();
  }

  return 0;
}
