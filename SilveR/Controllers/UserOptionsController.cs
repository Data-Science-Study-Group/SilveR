﻿using Microsoft.AspNetCore.Mvc;
using SilveR.Models;
using SilveR.Services;
using System;
using System.Threading.Tasks;

namespace SilveR.Controllers
{
    public class UserOptionsController : Controller
    {
        private readonly ISilveRRepository repository;

        public UserOptionsController(ISilveRRepository repository)
        {
            this.repository = repository;
        }

        [HttpGet]
        public async Task<IActionResult> Index()
        {
            UserOption options = await repository.GetUserOptions();
            return View(options);
        }

        [HttpPost]
        public async Task<IActionResult> UpdateUserOptions(UserOption userOption, string submitButtonValue)
        {
            if (submitButtonValue == "save")
            {
                await repository.UpdateUserOptions(userOption);
                return RedirectToAction("Index", "Home");
            }
            else if (submitButtonValue == "reset")
            {
                await repository.ResetUserOptions(userOption); //remove the useroptions

                return RedirectToAction ("Index");
            }
            else
                throw new ArgumentException("submitButtonValue is not valid!");
        }
    }
}