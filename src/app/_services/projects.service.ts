import { Injectable } from '@angular/core';
import { Project } from '../_models/Project';
import { Tag } from '../_models/Tag';

@Injectable({
  providedIn: 'root',
})
export class ProjectsService {
  projects: Project[] = [
    {
      id: 0,
      name: 'Objection!',
      pictures: [
        '../../assets/Objection1.png',
        '../../assets/Objection2.png',
        '../../assets/Objection3.png',
        '../../assets/Objection4.png',
      ],
      projectLink: '//devpost.com/software/objection',
      summary: 'Web extension to detect fake news',
      description:
        'Click on any web article and detect the possibility that it contains false news. Web extension uses a NLP classification model with 98% accuracy. LA Hacks Hackathon project that won third place amongst 70+ teams. ',
      tags: [Tag.JAVASCRIPT, Tag.PYTHON],
    },
    {
      id: 1,
      name: 'Retune',
      pictures: ['../../assets/Retune1.jpg', '../../assets/Retune2.png'],
      projectLink: '//www.instagram.com/p/CspHV6LvasV/?hl=en&img_index=3',
      summary: 'Location-based Music Discovery Mobile App',
      description:
        'Just like Snap Maps, Retune lets you explore the map to discover and connect with nearby friends and fellow listeners, turning music discovery into a social experience. Built by team of developers, marketers, and designers. App will be released to App store soon!',
      tags: [Tag.REACT, Tag.NODEJS],
    },
    {
      id: 2,
      name: 'Basketball Player Behavior Synthesis Research Paper',
      pictures: ['../../assets/Player1.png', '../../assets/Player2.png'],
      projectLink: '//arxiv.org/abs/2306.04090',
      summary: 'Diffusion ML model for generating optimal NBA tactics',
      description: `Given a snapshot of the positions of the players and the ball, 
        this machine learning model can generate the optimal play trajectories for the offensive team.
        I primarily assisted with the preprocessing of NBA motion tracking data and visualizing the model's results
        Paper is in submission to AAAI 2023 conference
        `,
      tags: [Tag.PYTHON],
    },
    {
      id: 3,
      name: 'Sumitup!',
      pictures: ['../../assets/Sumitup1.png'],
      projectLink:
        '//chrome.google.com/webstore/detail/sumitup/mjehellbildifhmgdjfionmbhlliddpj',
      summary: 'Web Extension to summarize text',
      description: `Chrome extension which utilizes Python NLTK library to 
        summarize articles which you can share with your friends.`,
      tags: [Tag.PYTHON, Tag.JAVASCRIPT],
    },
    {
      id: 4,
      name: 'Dinr',
      pictures: ['../../assets/Dinr1.png', '../../assets/Dinr2.png'],
      projectLink: '//github.com/MitchellParker/Dinr',
      summary:
        'Full-stack application for scheduling dining around the UCLA campus',
      description: `Web application that allows you to schedule your dining plans with your UCLA friends.
      Dinr allows you to pick a UCLA dining hall and a specific meal period. You can see your friends' schedule as well.
      Created this application as a class project in a team of 5.`,
      tags: [Tag.REACT, Tag.NODEJS],
    },
    {
      id: 5,
      name: 'GhostRacer',
      pictures: ['../../assets/GhostRacer1.png'],
      projectLink: '//github.com/AntonyXXu/GhostRacer-Game',
      summary: 'C++ object-oriented video game involving zombies and cars',
      description: `In this video game, your goal is to survive as long as you can on a freeway infested with zombies and zombie cars. 
      Class project for applying object oriented programming. Based on a UCLA CS 32 project and skeleton. Because of school policy, I am not allowed
      to post this project to github. But you can still check out this same project by a classmate who broke the rules lol.`,
      tags: [Tag.CPLUS],
    },
  ];
  constructor() {}

  GetProjects() {
    return this.projects;
  }
  GetProjectById(id: number): Project {
    let project = this.projects.find((project) => project.id === id);
    if (project === undefined) {
      throw new TypeError('There is no project that matches the id: ' + id);
    }
    return project;
  }

  GetProjectsByFilter(filterTags: Tag[]) {
    let filteredProjects: Project[] = [];

    this.projects.forEach(function (project) {
      let foundAll = true;

      filterTags.forEach(function (filterTag) {
        if (project.tags.includes(filterTag) == false) {
          foundAll = false;
        }
      });

      if (foundAll) {
        filteredProjects.push(project);
      }
    });

    return filteredProjects;
  }
}
