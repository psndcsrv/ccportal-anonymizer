#!/user/bin/env ruby

class NameGenerator
  FIRST_NAMES = %w{ Jacob Isabella Ethan Sophia Michael Emma Jayden Olivia William Ava
    Alexander Emily Noah Abigail Daniel Madison Aiden Chloe Anthony Mia Joshua Addison Mason
    Elizabeth Christopher Ella Andrew Natalie David Samantha Matthew Alexis Logan Lily Elijah
    Grace James Hailey Joseph Alyssa Gabriel Lillian Benjamin Hannah Ryan Avery Samuel Leah
    Jackson Nevaeh John Sofia Nathan Ashley Jonathan Anna Christian Brianna Liam Sarah Dylan
    Zoe Landon Victoria Caleb Gabriella Tyler Brooklyn Lucas Kaylee Evan Taylor Gavin Layla
    Nicholas Allison Isaac Evelyn Brayden Riley Luke Amelia Angel Khloe Brandon Makayla Jack
    Aubrey Isaiah Charlotte Jordan Savannah Owen Zoey Carter Bella Connor Kayla Justin Alexa
    Jose Peyton Jeremiah Audrey Julian Claire Robert Arianna Aaron Julia Adrian Aaliyah Wyatt
    Kylie Kevin Lauren Hunter Sophie Cameron Sydney Zachary Camila Thomas Jasmine Charles
    Morgan Austin Alexandra Eli Jocelyn Chase Gianna Henry Maya Sebastian Kimberly Jason
    Mackenzie Levi Katherine Xavier Destiny Ian Brooke Colton Trinity Dominic Faith Juan
    Lucy Cooper Madelyn Josiah Madeline Luis Bailey Ayden Payton Carson Andrea Adam Autumn
    Nathaniel Melanie Brody Ariana Tristan Serenity Diego Stella Parker Maria Blake Molly
    Oliver Caroline Cole Genesis Carlos Kaitlyn Jaden Eva Jesus Jessica Alex Angelina Aidan
    Valeria Eric Gabrielle Hayden Naomi Bryan Mariah Max Natalia Jaxon Paige Brian Rachel
  }

  LAST_NAMES = %w{ Smith Johnson Williams Jones Brown Davis Miller Wilson Moore Taylor Anderson
    Thomas Jackson White Harris Martin Thompson Garcia Martinez Robinson Clark Rodriguez Lewis Lee
    Walker Hall Allen Young Hernandez King Wright Lopez Hill Scott Green Adams Baker Gonzalez Nelson
    Carter Mitchell Perez Roberts Turner Phillips Campbell Parker Evans Edwards Collins Stewart Sanchez
    Morris Rogers Reed Cook Morgan Bell Murphy Bailey Rivera Cooper Richardson Cox Howard Ward Torres
    Peterson Gray Ramirez James Watson Brooks Kelly Sanders Price Bennett Wood Barnes Ross Henderson
    Coleman Jenkins Perry Powell Long Patterson Hughes Flores Washington Butler Simmons Foster Gonzales
    Bryant Alexander Russell Griffin Diaz Hayes Myers Ford Hamilton Graham Sullivan Wallace Woods Cole
    West Jordan Owens Reynolds Fisher Ellis Harrison Gibson Mcdonald Cruz Marshall Ortiz Gomez Murray
    Freeman Wells Webb Simpson Stevens Tucker Porter Hunter Hicks Crawford Henry Boyd Mason Morales
    Kennedy Warren Dixon Ramos Reyes Burns Gordon Shaw Holmes Rice Robertson Hunt Black Daniels Palmer
    Mills Nichols Grant Knight Ferguson Rose Stone Hawkins Dunn Perkins Hudson Spencer Gardner Stephens
    Payne Pierce Berry Matthews Arnold Wagner Willis Ray Watkins Olson Carroll Duncan Snyder Hart
    Cunningham Bradley Lane Andrews Ruiz Harper Fox Riley Armstrong Carpenter Weaver Greene Lawrence
    Elliott Chavez Sims Austin Peters Kelley Franklin Lawson
  }

  FIRST_FREQ = 40099
  FIRST_PHASE = 0
  LAST_FREQ = 40591
  LAST_PHASE = 4

  def self.get_name(id)
    ## Based on the concepts from: http://krazydad.com/tutorials/makecolors.php
    first_idx = (Math.sin(FIRST_FREQ*id + FIRST_PHASE) * 200 + 100 + 200).round % 200;
    last_idx = (Math.sin(LAST_FREQ*id + LAST_PHASE) * 200 + 100 + 200).round % 200;
    return [FIRST_NAMES[first_idx], LAST_NAMES[last_idx]]
  end
end
