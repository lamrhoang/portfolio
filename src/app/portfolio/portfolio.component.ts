import { Component, OnInit } from '@angular/core';
import { Title } from '@angular/platform-browser';
import { Project } from '../_models/Project';
import { Tag } from '../_models/Tag';
import { ProjectsService } from '../_services/projects.service';

@Component({
  selector: 'app-portfolio',
  templateUrl: './portfolio.component.html',
  styleUrls: ['./portfolio.component.css'],
})
export class PortfolioComponent implements OnInit {
  projects = {} as Project[];

  isCollapsed: boolean = true;
  typescript: boolean = false;
  javascript: boolean = false;
  python: boolean = false;
  csharp: boolean = false;
  java: boolean = false;
  angular: boolean = false;
  nodejs: boolean = false;
  aspnet: boolean = false;
  react: boolean = false;
  cplus: boolean = false;
  filtering: boolean = false;

  constructor(
    private titleService: Title,
    private projectService: ProjectsService
  ) {
    this.titleService.setTitle('Lam Hoang - Portfolio');
  }
  ngOnInit(): void {
    this.projects = this.projectService.GetProjects();
  }

  Filter() {
    let filterTags: Tag[] = [];

    if (this.typescript) {
      filterTags.push(Tag.TYPESCRIPT);
    }

    if (this.javascript) {
      filterTags.push(Tag.JAVASCRIPT);
    }

    if (this.python) {
      filterTags.push(Tag.PYTHON);
    }

    if (this.csharp) {
      filterTags.push(Tag.CSHARP);
    }

    if (this.java) {
      filterTags.push(Tag.JAVA);
    }

    if (this.angular) {
      filterTags.push(Tag.ANGULAR);
    }

    if (this.nodejs) {
      filterTags.push(Tag.NODEJS);
    }

    if (this.aspnet) {
      filterTags.push(Tag.ASPNET);
    }

    if (this.react) {
      filterTags.push(Tag.REACT);
    }

    if (this.cplus) {
      filterTags.push(Tag.CPLUS);
    }

    if (
      this.python ||
      this.csharp ||
      this.java ||
      this.angular ||
      this.typescript ||
      this.nodejs ||
      this.aspnet ||
      this.javascript ||
      this.react ||
      this.cplus
    ) {
      this.filtering = true;
    } else {
      this.filtering = false;
    }

    this.projects = this.projectService.GetProjectsByFilter(filterTags);
  }

  ResetFilters() {
    this.python = false;
    this.csharp = false;
    this.java = false;
    this.angular = false;
    this.typescript = false;
    this.nodejs = false;
    this.aspnet = false;
    this.javascript = false;
    this.react = false;
    this.cplus = false;
    this.filtering = false;

    this.projects = this.projectService.GetProjects();
  }
}
